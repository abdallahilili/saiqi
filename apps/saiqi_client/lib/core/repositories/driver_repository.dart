import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/booking_models.dart';
import '../models/driver_models.dart';
import '../models/enums.dart';
import '../models/json_utils.dart';

/// Côté chauffeur : dossier, véhicule, services, disponibilités, documents, statistiques.
class DriverRepository {
  DriverRepository(this._db);
  final SupabaseClient _db;

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const AppException('not_authenticated');
    return id;
  }

  Future<Driver?> myDriver() => guard(() async {
        final row = await _db.from('drivers').select().eq('profile_id', _uid).maybeSingle();
        return row == null ? null : Driver.fromJson(row);
      }, retries: 2);

  /// Dossier en temps réel : le statut (validation admin) apparaît sans rafraîchir.
  Stream<Driver?> watchMyDriver() {
    return _db
        .from('drivers')
        .stream(primaryKey: ['id'])
        .eq('profile_id', _uid)
        .map((rows) => rows.isEmpty ? null : Driver.fromJson(rows.first));
  }

  Future<void> updateDriverInfo({String? cityId, String? bio, int? yearsExperience}) => guard(() async {
        await _db.from('drivers').update({
          'city_id': ?cityId,
          'bio': ?(bio == null ? null : (bio.trim().isEmpty ? null : bio.trim())),
          'years_experience': ?yearsExperience,
        }).eq('profile_id', _uid);
      });

  // ---- véhicule ------------------------------------------------------------
  Future<Vehicle?> myVehicle(String driverId) => guard(() async {
        final row = await _db.from('vehicles').select().eq('driver_id', driverId).maybeSingle();
        return row == null ? null : Vehicle.fromJson(row);
      }, retries: 2);

  Future<Vehicle> saveVehicle(Vehicle v) => guard(() async {
        final row = await _db.from('vehicles').upsert(v.toJson(), onConflict: 'driver_id').select().single();
        return Vehicle.fromJson(row);
      });

  // ---- services ------------------------------------------------------------
  Future<List<DriverService>> myServices(String driverId) => guard(() async {
        final rows = await _db.from('driver_services').select().eq('driver_id', driverId).order('created_at');
        return rows.map(DriverService.fromJson).toList();
      }, retries: 2);

  Future<void> saveService(DriverService s) => guard(() async {
        await _db.from('driver_services').upsert(s.toJson(), onConflict: 'driver_id,service_type_id');
      });

  Future<void> deleteService(String id) => guard(() async {
        await _db.from('driver_services').delete().eq('id', id);
      });

  // ---- disponibilités ---------------------------------------------------------
  Future<List<DriverAvailability>> myAvailability(String driverId) => guard(() async {
        final rows = await _db.from('driver_availability').select().eq('driver_id', driverId).order('weekday');
        return rows.map(DriverAvailability.fromJson).toList();
      }, retries: 2);

  Future<void> replaceAvailability(String driverId, List<DriverAvailability> slots) => guard(() async {
        await _db.from('driver_availability').delete().eq('driver_id', driverId);
        if (slots.isEmpty) return;
        await _db.from('driver_availability').insert([
          for (final s in slots)
            {'driver_id': driverId, 'weekday': s.weekday, 'start_time': s.start, 'end_time': s.end},
        ]);
      });

  // ---- documents ---------------------------------------------------------------
  Future<List<DriverDocument>> myDocuments(String driverId) => guard(() async {
        final rows = await _db.from('driver_documents').select().eq('driver_id', driverId);
        return rows.map(DriverDocument.fromJson).toList();
      }, retries: 2);

  Stream<List<DriverDocument>> watchDocuments(String driverId) {
    return _db
        .from('driver_documents')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .map((rows) => rows.map(DriverDocument.fromJson).toList());
  }

  Future<DriverDocument> saveDocument(DocumentType type, String filePath) => guard(() async {
        final res = await _db.rpc('save_driver_document', params: {'p_type': type.db, 'p_file_path': filePath});
        return DriverDocument.fromJson(asJson(res));
      });

  Future<Driver> submitApplication() => guard(() async {
        final res = await _db.rpc('submit_driver_application');
        return Driver.fromJson(asJson(res));
      });

  Future<Driver> setAvailable(bool available) => guard(() async {
        final res = await _db.rpc('set_driver_availability', params: {'p_available': available});
        return Driver.fromJson(asJson(res));
      });

  Future<DriverStats> stats() => guard(() async {
        final res = await _db.rpc('driver_stats');
        return DriverStats.fromJson(asJson(res));
      }, retries: 2);

  /// Avis reçus (non masqués) avec le prénom du client.
  Future<List<Review>> myReviews(String driverId) => guard(() async {
        final rows = await _db
            .from('public_driver_reviews')
            .select()
            .eq('driver_id', driverId)
            .order('created_at', ascending: false)
            .limit(100);
        return rows.map(Review.fromJson).toList();
      }, retries: 2);

  Future<void> reportProblem(String text) => guard(() async {
        await _db.rpc('file_complaint', params: {'p_booking_id': null, 'p_text': text});
      });
}
