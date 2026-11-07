import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core.dart';

/// Ville choisie (mémorisée). Par défaut : première ville active du catalogue.
class SelectedCityNotifier extends Notifier<String?> {
  static const _key = 'pref.client_city';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  Future<void> set(String? id) async {
    state = id;
    final prefs = ref.read(sharedPreferencesProvider);
    if (id == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, id);
    }
  }
}

final selectedCityProvider = NotifierProvider<SelectedCityNotifier, String?>(SelectedCityNotifier.new);

/// Ville effective : celle choisie si elle existe encore, sinon la première du catalogue.
final effectiveCityProvider = Provider<String?>((ref) {
  final cities = ref.watch(citiesProvider).value ?? const <City>[];
  final chosen = ref.watch(selectedCityProvider);
  if (chosen != null && cities.any((c) => c.id == chosen)) return chosen;
  return cities.isEmpty ? null : cities.first.id;
});

/// Critères de recherche de chauffeurs (record : égalité par valeur, clé de cache du provider famille).
typedef DriverQuery = ({
  String? cityId,
  String? serviceTypeId,
  int? minPrice,
  int? maxPrice,
  double? minRating,
  int? minSeats,
  String? vehicleType,
  bool onlyAvailable,
  String sort,
});

extension DriverQueryX on DriverQuery {
  int get activeFilterCount =>
      [minPrice, maxPrice, minRating, minSeats, vehicleType].where((v) => v != null).length + (onlyAvailable ? 0 : 1);
}

final driversSearchProvider = FutureProvider.autoDispose.family<List<PublicDriver>, DriverQuery>((ref, q) {
  return ref.watch(publicDriverRepositoryProvider).search(
        cityId: q.cityId,
        serviceTypeId: q.serviceTypeId,
        minPrice: q.minPrice,
        maxPrice: q.maxPrice,
        minRating: q.minRating,
        minSeats: q.minSeats,
        vehicleType: q.vehicleType,
        onlyAvailable: q.onlyAvailable,
        sort: q.sort,
      );
});

final publicDriverProvider = FutureProvider.autoDispose.family<PublicDriver?, String>(
  (ref, id) => ref.watch(publicDriverRepositoryProvider).getDriver(id),
);

final publicServicesProvider = FutureProvider.autoDispose.family<List<PublicDriverService>, String>(
  (ref, id) => ref.watch(publicDriverRepositoryProvider).services(id),
);

final publicReviewsProvider = FutureProvider.autoDispose.family<List<Review>, String>(
  (ref, id) => ref.watch(publicDriverRepositoryProvider).reviews(id),
);

/// Favoris du client (ids de chauffeurs) avec bascule optimiste.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final uid = await ref.watch(authUserIdProvider.future);
    if (uid == null) return <String>{};
    return ref.read(publicDriverRepositoryProvider).favoriteIds();
  }

  Future<bool> toggle(String driverId) async {
    final current = {...(state.value ?? <String>{})};
    final adding = !current.contains(driverId);
    state = AsyncData(adding ? ({...current, driverId}) : (current..remove(driverId)));
    try {
      final repo = ref.read(publicDriverRepositoryProvider);
      adding ? await repo.addFavorite(driverId) : await repo.removeFavorite(driverId);
      ref.invalidate(favoriteDriversProvider);
    } catch (_) {
      ref.invalidateSelf(); // retour à l'état serveur en cas d'échec
      rethrow;
    }
    return adding;
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

final favoriteDriversProvider = FutureProvider.autoDispose<List<PublicDriver>>((ref) {
  ref.watch(favoritesProvider);
  return ref.watch(publicDriverRepositoryProvider).favoriteDrivers();
});

// ---- réservations --------------------------------------------------------------------
final myBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final uid = ref.watch(authUserIdProvider).value;
  if (uid == null) return Stream.value(const []);
  return ref.watch(bookingRepositoryProvider).watchMyBookings();
});

/// Suivi en temps réel d'une réservation.
final bookingProvider = StreamProvider.autoDispose.family<Booking, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).watchBooking(id),
);

final bookingDriverProvider = FutureProvider.autoDispose.family<BookingDriverInfo?, String>((ref, id) async {
  ref.watch(bookingProvider(id)); // se recharge quand le statut change
  return ref.watch(bookingRepositoryProvider).bookingDriver(id);
});

final driverContactProvider = FutureProvider.autoDispose.family<BookingContact, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).contact(id),
);

final reviewForBookingProvider = FutureProvider.autoDispose.family<Review?, String>((ref, id) {
  ref.watch(bookingProvider(id));
  return ref.watch(bookingRepositoryProvider).reviewForBooking(id);
});
