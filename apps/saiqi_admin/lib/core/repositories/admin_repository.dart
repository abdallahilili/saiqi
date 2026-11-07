import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/booking_models.dart';
import '../models/catalog_models.dart';
import '../models/driver_models.dart';
import '../models/enums.dart';
import '../models/json_utils.dart';
import '../models/misc_models.dart';
import '../models/wallet_models.dart';
import '../utils/phone.dart';

/// Toutes les opérations de l'app Admin. Les droits réels sont imposés côté SQL (RLS + admin_role).
class AdminRepository {
  AdminRepository(this._db);
  final SupabaseClient _db;

  static const _driverSelect =
      '*, profiles!inner(full_name,phone,avatar_url,status), cities(name_ar,name_fr), wallets(balance)';

  // ===== Tableau de bord =====================================================
  Future<AdminStats> dashboardStats() => guard(() async {
        final res = await _db.rpc('admin_dashboard_stats');
        return AdminStats(asJson(res));
      }, retries: 2);

  // ===== Chauffeurs ==========================================================
  Future<List<AdminDriver>> listDrivers({DriverStatus? status}) => guard(() async {
        var q = _db.from('drivers').select(_driverSelect);
        if (status != null) q = q.eq('status', status.db);
        final rows = await q.order('created_at', ascending: false).limit(300);
        return rows.map(AdminDriver.fromJson).toList();
      }, retries: 2);

  Future<AdminDriver> getDriver(String driverId) => guard(() async {
        final row = await _db.from('drivers').select(_driverSelect).eq('id', driverId).single();
        return AdminDriver.fromJson(row);
      }, retries: 2);

  Future<List<DriverDocument>> driverDocuments(String driverId) => guard(() async {
        final rows = await _db.from('driver_documents').select().eq('driver_id', driverId);
        return rows.map(DriverDocument.fromJson).toList();
      }, retries: 2);

  Future<Vehicle?> driverVehicle(String driverId) => guard(() async {
        final row = await _db.from('vehicles').select().eq('driver_id', driverId).maybeSingle();
        return row == null ? null : Vehicle.fromJson(row);
      }, retries: 2);

  Future<List<DriverService>> driverServices(String driverId) => guard(() async {
        final rows = await _db.from('driver_services').select().eq('driver_id', driverId);
        return rows.map(DriverService.fromJson).toList();
      }, retries: 2);

  Future<void> reviewDriver(String driverId, {required bool approve, String? reason}) => guard(() async {
        await _db.rpc('admin_review_driver', params: {'p_driver_id': driverId, 'p_approve': approve, 'p_reason': reason});
      });

  Future<void> reviewDocument(String documentId, {required bool approve, String? reason}) => guard(() async {
        await _db.rpc('admin_review_document', params: {'p_document_id': documentId, 'p_approve': approve, 'p_reason': reason});
      });

  Future<void> setDriverStatus(String driverId, DriverStatus status, {String? reason}) => guard(() async {
        await _db.rpc('admin_set_driver_status', params: {'p_driver_id': driverId, 'p_status': status.db, 'p_reason': reason});
      });

  Future<void> setAccountStatus(String profileId, AccountStatus status, {String? reason}) => guard(() async {
        await _db.rpc('admin_set_account_status', params: {'p_profile_id': profileId, 'p_status': status.db, 'p_reason': reason});
      });

  // ===== Réservations =========================================================
  Future<List<Booking>> listBookings({
    BookingStatus? status,
    String? cityId,
    BookingChannel? channel,
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) =>
      guard(() async {
        var q = _db.from('bookings').select(Booking.adminSelect);
        if (status != null) q = q.eq('status', status.db);
        if (cityId != null) q = q.eq('city_id', cityId);
        if (channel != null) q = q.eq('channel', channel.db);
        if (from != null) q = q.gte('scheduled_at', from.toUtc().toIso8601String());
        if (to != null) q = q.lt('scheduled_at', to.toUtc().toIso8601String());
        final rows = await q.order('created_at', ascending: false).limit(limit);
        return rows.map(Booking.fromJson).toList();
      }, retries: 2);

  Future<Booking> getBooking(String id) => guard(() async {
        final row = await _db.from('bookings').select(Booking.adminSelect).eq('id', id).single();
        return Booking.fromJson(row);
      }, retries: 2);

  /// Mise à jour en temps réel : relit la réservation à chaque changement.
  Stream<Booking> watchBooking(String id) async* {
    yield await getBooking(id);
    await for (final _ in _db.from('bookings').stream(primaryKey: ['id']).eq('id', id).skip(1)) {
      yield await getBooking(id);
    }
  }

  Future<List<BookingOffer>> bookingOffers(String bookingId) => guard(() async {
        final rows = await _db
            .from('booking_offers')
            .select('*, drivers(profiles(full_name,phone))')
            .eq('booking_id', bookingId)
            .order('created_at');
        return rows.map(BookingOffer.fromJson).toList();
      }, retries: 2);

  Future<Booking> createBooking({
    required String clientName,
    required String clientPhone,
    required String serviceTypeId,
    required String cityId,
    required String pickupText,
    String? dropoffText,
    required DateTime scheduledAt,
    int passengers = 1,
    String? notes,
    required int price,
    required BookingChannel channel,
    required List<String> driverIds,
  }) =>
      guard(() async {
        final res = await _db.rpc('admin_create_booking', params: {
          'p_client_name': clientName,
          'p_client_phone': clientPhone,
          'p_service_type_id': serviceTypeId,
          'p_city_id': cityId,
          'p_pickup_text': pickupText,
          'p_dropoff_text': dropoffText,
          'p_scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'p_passengers': passengers,
          'p_notes': notes,
          'p_price': price,
          'p_channel': channel.db,
          'p_driver_ids': driverIds,
        });
        return Booking.fromJson(asJson(res));
      });

  Future<Booking> reassignBooking(String bookingId, List<String> driverIds) => guard(() async {
        final res = await _db.rpc('admin_reassign_booking', params: {'p_booking_id': bookingId, 'p_driver_ids': driverIds});
        return Booking.fromJson(asJson(res));
      });

  Future<void> cancelBooking(String bookingId, {String? reason}) => guard(() async {
        await _db.rpc('cancel_booking', params: {'p_booking_id': bookingId, 'p_reason': reason});
      });

  // ===== Portefeuilles / recharges ==================================================
  Future<List<TopupRequest>> listTopups({TopupStatus? status}) => guard(() async {
        var q = _db.from('topup_requests').select('*, drivers(profiles(full_name,phone))');
        if (status != null) q = q.eq('status', status.db);
        final rows = await q.order('created_at', ascending: false).limit(200);
        return rows.map(TopupRequest.fromJson).toList();
      }, retries: 2);

  Future<void> reviewTopup(String topupId, {required bool approve, String? note}) => guard(() async {
        await _db.rpc('admin_review_topup', params: {'p_topup_id': topupId, 'p_approve': approve, 'p_note': note});
      });

  Future<void> adjustWallet(String driverId, int amount, String note) => guard(() async {
        await _db.rpc('admin_adjust_wallet', params: {'p_driver_id': driverId, 'p_amount': amount, 'p_note': note});
      });

  Future<Wallet?> driverWallet(String driverId) => guard(() async {
        final row = await _db.from('wallets').select().eq('driver_id', driverId).maybeSingle();
        return row == null ? null : Wallet.fromJson(row);
      }, retries: 2);

  Future<List<WalletTx>> walletTransactions(String walletId, {int limit = 100}) => guard(() async {
        final rows = await _db
            .from('wallet_transactions')
            .select()
            .eq('wallet_id', walletId)
            .order('created_at', ascending: false)
            .limit(limit);
        return rows.map(WalletTx.fromJson).toList();
      }, retries: 2);

  // ===== Commissions et réglages ======================================================
  Future<List<CommissionRecord>> commissionHistory({int limit = 100}) => guard(() async {
        final rows = await _db
            .from('commissions')
            .select('*, drivers(profiles(full_name)), bookings(service_types(name_ar,name_fr))')
            .order('created_at', ascending: false)
            .limit(limit);
        return rows.map(CommissionRecord.fromJson).toList();
      }, retries: 2);

  Future<void> upsertCommissionRate({String? id, required double rate, String? serviceTypeId, String? cityId}) =>
      guard(() async {
        final data = {'rate': rate, 'service_type_id': serviceTypeId, 'city_id': cityId};
        if (id == null) {
          await _db.from('commission_rates').insert(data);
        } else {
          await _db.from('commission_rates').update(data).eq('id', id);
        }
      });

  Future<void> deleteCommissionRate(String id) => guard(() async {
        await _db.from('commission_rates').delete().eq('id', id);
      });

  Future<void> setSetting(String key, Object? value) => guard(() async {
        await _db.from('app_settings').upsert({'key': key, 'value': value}, onConflict: 'key');
      });

  // ===== Plaintes et avis ===================================================================
  Future<List<Complaint>> listComplaints({ComplaintStatus? status}) => guard(() async {
        var q = _db.from('complaints').select(
            '*, author:profiles!complaints_author_id_fkey(full_name,phone), against:profiles!complaints_against_id_fkey(full_name,phone)');
        if (status != null) q = q.eq('status', status.db);
        final rows = await q.order('created_at', ascending: false).limit(200);
        return rows.map(Complaint.fromJson).toList();
      }, retries: 2);

  Future<void> handleComplaint(String id, ComplaintStatus status, {String? resolution}) => guard(() async {
        await _db.rpc('admin_handle_complaint', params: {'p_complaint_id': id, 'p_status': status.db, 'p_resolution': resolution});
      });

  Future<List<Review>> listReviews({bool? hidden}) => guard(() async {
        var q = _db.from('reviews').select('*, drivers(profiles(full_name)), client:profiles!reviews_client_id_fkey(full_name)');
        if (hidden != null) q = q.eq('is_hidden', hidden);
        final rows = await q.order('created_at', ascending: false).limit(200);
        return rows.map(Review.fromJson).toList();
      }, retries: 2);

  Future<void> moderateReview(String id, {required bool hidden}) => guard(() async {
        await _db.rpc('admin_moderate_review', params: {'p_review_id': id, 'p_hidden': hidden});
      });

  // ===== Utilisateurs ==========================================================================
  Future<List<ProfileSummary>> listProfiles(UserRole role) => guard(() async {
        final rows = await _db.from('profiles').select().eq('role', role.db).order('created_at', ascending: false).limit(500);
        return rows.map(ProfileSummary.fromJson).toList();
      }, retries: 2);

  Future<void> setAdminRole(String profileId, AdminRole role) => guard(() async {
        await _db.rpc('admin_set_admin_role', params: {'p_profile_id': profileId, 'p_admin_role': role.db});
      });

  /// Création d'un compte de l'équipe (Edge Function `admin-create-admin`, super_admin uniquement).
  Future<void> createAdmin({
    required String phone,
    required String password,
    required String fullName,
    required AdminRole role,
  }) =>
      guard(() async {
        final normalized = PhoneUtils.normalize(phone);
        if (normalized == null) throw const AppException('invalid_phone');
        await _db.functions.invoke('admin-create-admin', body: {
          'phone': normalized,
          'password': password,
          'full_name': fullName,
          'admin_role': role.db,
        });
      });

  /// Réinitialisation du mot de passe d'un utilisateur (Edge Function `admin-reset-password`).
  Future<void> resetPassword({required String userId, required String newPassword}) => guard(() async {
        await _db.functions.invoke('admin-reset-password', body: {'user_id': userId, 'new_password': newPassword});
      });

  Future<void> warnUser(String profileId, String message) => guard(() async {
        await _db.rpc('admin_warn_user', params: {'p_profile_id': profileId, 'p_message': message});
      });

  // ===== Catalogues ===============================================================================
  Future<void> saveCity(City c, {bool isNew = false}) => guard(() async {
        final data = {'name_ar': c.nameAr, 'name_fr': c.nameFr, 'is_active': c.isActive};
        if (isNew) {
          await _db.from('cities').insert(data);
        } else {
          await _db.from('cities').update(data).eq('id', c.id);
        }
      });

  Future<void> deleteCity(String id) => guard(() async {
        await _db.from('cities').delete().eq('id', id);
      });

  Future<void> saveServiceType(ServiceType s, {bool isNew = false}) => guard(() async {
        final data = {'name_ar': s.nameAr, 'name_fr': s.nameFr, 'icon': s.icon, 'is_active': s.isActive};
        if (isNew) {
          await _db.from('service_types').insert(data);
        } else {
          await _db.from('service_types').update(data).eq('id', s.id);
        }
      });

  Future<void> deleteServiceType(String id) => guard(() async {
        await _db.from('service_types').delete().eq('id', id);
      });

  // ===== Audit et annonces ===========================================================================
  Future<List<AuditLog>> auditLogs({int limit = 150}) => guard(() async {
        final rows = await _db
            .from('audit_logs')
            .select('*, actor:profiles!audit_logs_actor_id_fkey(full_name,phone)')
            .order('created_at', ascending: false)
            .limit(limit);
        return rows.map(AuditLog.fromJson).toList();
      }, retries: 2);

  Future<List<Announcement>> announcements() => guard(() async {
        final rows = await _db.from('announcements').select().order('created_at', ascending: false).limit(50);
        return rows.map(Announcement.fromJson).toList();
      }, retries: 2);

  Future<void> sendAnnouncement({required String audience, required String title, required String body}) => guard(() async {
        await _db.rpc('admin_send_announcement', params: {'p_audience': audience, 'p_title': title, 'p_body': body});
      });
}
