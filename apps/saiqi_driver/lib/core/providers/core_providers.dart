import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/catalog_models.dart';
import '../models/enums.dart';
import '../notifications/push_service.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/driver_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/public_driver_repository.dart';
import '../repositories/storage_repository.dart';
import '../repositories/wallet_repository.dart';
import '../utils/json_cache.dart';

// ---------------------------------------------------------------------------
// Infrastructure (à surcharger dans main : sharedPreferences, expectedRole)
// ---------------------------------------------------------------------------
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider doit être surchargé dans main()'),
);

/// Rôle autorisé dans l'app courante (client / driver / admin).
final expectedRoleProvider = Provider<UserRole>(
  (ref) => throw UnimplementedError('expectedRoleProvider doit être surchargé dans main()'),
);

final jsonCacheProvider = Provider<JsonCache>((ref) => JsonCache(ref.watch(sharedPreferencesProvider)));

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------
final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository(ref.watch(supabaseProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(supabaseProvider)));
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(supabaseProvider), ref.watch(jsonCacheProvider)),
);
final driverRepositoryProvider = Provider<DriverRepository>((ref) => DriverRepository(ref.watch(supabaseProvider)));
final publicDriverRepositoryProvider =
    Provider<PublicDriverRepository>((ref) => PublicDriverRepository(ref.watch(supabaseProvider)));
final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository(ref.watch(supabaseProvider)));
final walletRepositoryProvider = Provider<WalletRepository>((ref) => WalletRepository(ref.watch(supabaseProvider)));
final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository(ref.watch(supabaseProvider)));
final storageRepositoryProvider = Provider<StorageRepository>((ref) => StorageRepository(ref.watch(supabaseProvider)));

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref.watch(authRepositoryProvider)));

// ---------------------------------------------------------------------------
// Langue et thème (persistés)
// ---------------------------------------------------------------------------
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'pref.locale';

  @override
  Locale build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_key);
    return Locale(code == 'fr' ? 'fr' : 'ar');
  }

  /// Change la langue de l'interface et, si connecté, celle des notifications serveur.
  Future<void> setLanguage(String code) async {
    final lang = code == 'fr' ? 'fr' : 'ar';
    state = Locale(lang);
    await ref.read(sharedPreferencesProvider).setString(_key, lang);
    await ref.read(sharedPreferencesProvider).setBool('pref.language_chosen', true);
    if (ref.read(supabaseProvider).auth.currentUser != null) {
      try {
        await ref.read(authRepositoryProvider).updateProfile(language: lang);
      } catch (_) {
        // la langue locale est appliquée même hors-ligne
      }
    }
  }

  /// Aligne la langue locale sur celle du profil au moment de la connexion.
  void adoptFromProfile(String lang) {
    final l = lang == 'fr' ? 'fr' : 'ar';
    if (state.languageCode != l) {
      state = Locale(l);
      unawaited(ref.read(sharedPreferencesProvider).setString(_key, l));
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Vrai une fois que l'utilisateur a choisi sa langue (écran de bienvenue).
final languageChosenProvider = Provider<bool>((ref) {
  ref.watch(localeProvider); // se recalcule quand la langue change
  return ref.watch(sharedPreferencesProvider).getBool('pref.language_chosen') ?? false;
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'pref.theme';

  @override
  ThemeMode build() {
    return switch (ref.watch(sharedPreferencesProvider).getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ---------------------------------------------------------------------------
// Session et profil
// ---------------------------------------------------------------------------
/// Identifiant de l'utilisateur connecté (null si déconnecté). Réagit aux changements de session.
final authUserIdProvider = StreamProvider<String?>((ref) async* {
  final client = ref.watch(supabaseProvider);
  yield client.auth.currentUser?.id;
  await for (final state in client.auth.onAuthStateChange) {
    yield state.session?.user.id;
  }
});

class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    final uid = await ref.watch(authUserIdProvider.future);
    if (uid == null) return null;
    final profile = await ref.read(authRepositoryProvider).fetchProfile(uid);
    ref.read(localeProvider.notifier).adoptFromProfile(profile.language);
    return profile;
  }

  void set(Profile? profile) => state = AsyncData(profile);

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(ProfileNotifier.new);

/// Actions d'authentification (état = opération en cours / erreur).
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signIn({required String phone, required String password}) async {
    state = const AsyncLoading();
    try {
      final profile = await ref.read(authRepositoryProvider).signIn(
            phone: phone,
            password: password,
            expectedRole: ref.read(expectedRoleProvider),
          );
      ref.read(profileProvider.notifier).set(profile);
      ref.read(localeProvider.notifier).adoptFromProfile(profile.language);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapError(e), st);
      return false;
    }
  }

  Future<bool> signUp({required String phone, required String password, String? fullName}) async {
    state = const AsyncLoading();
    try {
      final profile = await ref.read(authRepositoryProvider).signUp(
            phone: phone,
            password: password,
            fullName: fullName,
            role: ref.read(expectedRoleProvider),
            language: ref.read(localeProvider).languageCode,
          );
      ref.read(profileProvider.notifier).set(profile);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapError(e), st);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(pushServiceProvider).unregister();
    } catch (_) {}
    try {
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      ref.read(profileProvider.notifier).set(null);
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

// ---------------------------------------------------------------------------
// Catalogues (mis en cache)
// ---------------------------------------------------------------------------
final citiesProvider = FutureProvider<List<City>>((ref) => ref.watch(catalogRepositoryProvider).cities());
final serviceTypesProvider =
    FutureProvider<List<ServiceType>>((ref) => ref.watch(catalogRepositoryProvider).serviceTypes());
final appSettingsProvider = FutureProvider<AppSettings>((ref) => ref.watch(catalogRepositoryProvider).settings());

/// Notifications non lues (badge).
final unreadNotificationsProvider = StreamProvider<int>((ref) {
  final uid = ref.watch(authUserIdProvider).value;
  if (uid == null) return Stream.value(0);
  return ref.watch(notificationRepositoryProvider).watch().map((l) => l.where((n) => !n.isRead).length);
});
