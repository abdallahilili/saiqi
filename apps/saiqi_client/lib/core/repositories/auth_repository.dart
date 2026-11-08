import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/catalog_models.dart';
import '../models/enums.dart';
import '../utils/phone.dart';

/// Authentification par numéro de téléphone + mot de passe (aucun SMS/OTP).
/// Implémentation : Supabase Auth email/mot de passe avec un email technique dérivé du numéro.
class AuthRepository {
  AuthRepository(this._db);
  final SupabaseClient _db;

  User? get currentUser => _db.auth.currentUser;
  Stream<AuthState> get authChanges => _db.auth.onAuthStateChange;

  Future<Profile> fetchProfile(String userId) => guard(() async {
        final row = await _db.from('profiles').select().eq('id', userId).single();
        return Profile.fromJson(row);
      }, retries: 2);

  Future<Profile> signUp({
    required String phone,
    required String password,
    required UserRole role,
    required String language,
    String? fullName,
  }) =>
      guard(() async {
        final normalized = PhoneUtils.normalize(phone);
        if (normalized == null) throw const AppException('invalid_phone');
        if (password.length < 8) throw const AppException('password_too_short');
        if (role != UserRole.client && role != UserRole.driver) {
          throw const AppException('permission_denied');
        }
        // Via Edge Function (Auth Admin) pour éviter le rate-limit GoTrue sur /signup.
        await _db.functions.invoke('signup', body: {
          'phone': normalized,
          'password': password,
          'role': role.db,
          'language': language,
          if (fullName != null && fullName.trim().isNotEmpty) 'full_name': fullName.trim(),
        });
        final res = await _db.auth.signInWithPassword(
          email: PhoneUtils.technicalEmail(normalized),
          password: password,
        );
        final user = res.user;
        if (user == null) throw const AppException('signup_failed');
        return _ensureAllowed(await fetchProfile(user.id), role);
      });

  Future<Profile> signIn({
    required String phone,
    required String password,
    required UserRole expectedRole,
  }) =>
      guard(() async {
        final normalized = PhoneUtils.normalize(phone);
        if (normalized == null) throw const AppException('invalid_phone');
        final res = await _db.auth.signInWithPassword(
          email: PhoneUtils.technicalEmail(normalized),
          password: password,
        );
        final user = res.user;
        if (user == null) throw const AppException('invalid_credentials');
        return _ensureAllowed(await fetchProfile(user.id), expectedRole);
      });

  /// Refuse l'accès si le compte n'appartient pas à cette app ou n'est pas actif (et déconnecte).
  Future<Profile> _ensureAllowed(Profile profile, UserRole expected) async {
    AppException? problem;
    if (profile.role != expected) {
      problem = const AppException('wrong_app_role');
    } else if (profile.status == AccountStatus.suspended) {
      problem = const AppException('account_suspended');
    } else if (profile.status == AccountStatus.blocked) {
      problem = const AppException('account_blocked');
    }
    if (problem != null) {
      await _db.auth.signOut();
      throw problem;
    }
    return profile;
  }

  Future<void> signOut() => guard(() => _db.auth.signOut());

  Future<Profile> updateProfile({String? fullName, String? avatarUrl, String? language}) => guard(() async {
        final uid = currentUser?.id;
        if (uid == null) throw const AppException('not_authenticated');
        final patch = <String, dynamic>{
          'full_name': ?fullName?.trim(),
          'avatar_url': ?avatarUrl,
          'language': ?language,
        };
        final row = await _db.from('profiles').update(patch).eq('id', uid).select().single();
        return Profile.fromJson(row);
      });

  Future<void> setFcmToken(String? token) => guard(() async {
        final uid = currentUser?.id;
        if (uid == null) return;
        await _db.from('profiles').update({'fcm_token': token}).eq('id', uid);
      });

  /// Change le mot de passe après avoir revérifié l'ancien.
  Future<void> changePassword({required String currentPassword, required String newPassword}) => guard(() async {
        if (newPassword.length < 8) throw const AppException('password_too_short');
        final user = currentUser;
        if (user == null) throw const AppException('not_authenticated');
        final profile = await fetchProfile(user.id);
        await _db.auth.signInWithPassword(
          email: PhoneUtils.technicalEmail(profile.phone),
          password: currentPassword,
        );
        await _db.auth.updateUser(UserAttributes(password: newPassword));
      });
}
