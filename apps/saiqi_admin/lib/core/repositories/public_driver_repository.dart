import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/booking_models.dart';
import '../models/driver_models.dart';
import '../models/json_utils.dart';

/// Recherche et consultation de chauffeurs (côté client). Aucune donnée de contact n'y figure.
class PublicDriverRepository {
  PublicDriverRepository(this._db);
  final SupabaseClient _db;

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const AppException('not_authenticated');
    return id;
  }

  Future<List<PublicDriver>> search({
    String? cityId,
    String? serviceTypeId,
    int? minPrice,
    int? maxPrice,
    double? minRating,
    int? minSeats,
    String? vehicleType,
    bool onlyAvailable = true,
    String sort = 'rating',
    int limit = 50,
    int offset = 0,
  }) =>
      guard(() async {
        final res = await _db.rpc('search_drivers', params: {
          'p_city_id': cityId,
          'p_service_type_id': serviceTypeId,
          'p_min_price': minPrice,
          'p_max_price': maxPrice,
          'p_min_rating': minRating,
          'p_min_seats': minSeats,
          'p_vehicle_type': vehicleType,
          'p_only_available': onlyAvailable,
          'p_sort': sort,
          'p_limit': limit,
          'p_offset': offset,
        });
        return asJsonList(res).map(PublicDriver.fromJson).toList();
      }, retries: 2);

  Future<PublicDriver?> getDriver(String driverId) => guard(() async {
        final row = await _db.from('public_drivers').select().eq('driver_id', driverId).maybeSingle();
        return row == null ? null : PublicDriver.fromJson(row);
      }, retries: 2);

  Future<List<PublicDriverService>> services(String driverId) => guard(() async {
        final rows = await _db.from('public_driver_services').select().eq('driver_id', driverId);
        return rows.map(PublicDriverService.fromJson).toList();
      }, retries: 2);

  Future<List<Review>> reviews(String driverId, {int limit = 50}) => guard(() async {
        final rows = await _db
            .from('public_driver_reviews')
            .select()
            .eq('driver_id', driverId)
            .order('created_at', ascending: false)
            .limit(limit);
        return rows.map(Review.fromJson).toList();
      }, retries: 2);

  // ---- favoris -------------------------------------------------------------------
  Future<Set<String>> favoriteIds() => guard(() async {
        final rows = await _db.from('favorites').select('driver_id').eq('client_id', _uid);
        return rows.map((r) => r['driver_id'] as String).toSet();
      }, retries: 2);

  Future<void> addFavorite(String driverId) => guard(() async {
        await _db.from('favorites').upsert(
          {'client_id': _uid, 'driver_id': driverId},
          onConflict: 'client_id,driver_id',
          ignoreDuplicates: true,
        );
      });

  Future<void> removeFavorite(String driverId) => guard(() async {
        await _db.from('favorites').delete().eq('client_id', _uid).eq('driver_id', driverId);
      });

  Future<List<PublicDriver>> favoriteDrivers() => guard(() async {
        final ids = await favoriteIds();
        if (ids.isEmpty) return <PublicDriver>[];
        final rows = await _db.from('public_drivers').select().inFilter('driver_id', ids.toList());
        return rows.map(PublicDriver.fromJson).toList();
      }, retries: 2);
}
