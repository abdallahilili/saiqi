import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/booking_models.dart';
import '../models/enums.dart';
import '../models/json_utils.dart';

/// Réservations côté client et côté chauffeur. Toute transition passe par une fonction SQL.
class BookingRepository {
  BookingRepository(this._db);
  final SupabaseClient _db;

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const AppException('not_authenticated');
    return id;
  }

  // ===== Client ================================================================
  Future<Booking> createBooking({
    required String driverId,
    required String serviceTypeId,
    required String cityId,
    required String pickupText,
    String? dropoffText,
    required DateTime scheduledAt,
    int passengers = 1,
    String? notes,
  }) =>
      guard(() async {
        final res = await _db.rpc('create_booking', params: {
          'p_driver_id': driverId,
          'p_service_type_id': serviceTypeId,
          'p_city_id': cityId,
          'p_pickup_text': pickupText,
          'p_dropoff_text': dropoffText,
          'p_scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'p_passengers': passengers,
          'p_notes': notes,
        });
        return Booking.fromJson(asJson(res));
      });

  Future<List<Booking>> myBookings() => guard(() async {
        final rows = await _db
            .from('bookings')
            .select(Booking.select)
            .eq('client_id', _uid)
            .order('created_at', ascending: false)
            .limit(100);
        return rows.map(Booking.fromJson).toList();
      }, retries: 2);

  Stream<List<Booking>> watchMyBookings() async* {
    yield await myBookings();
    await for (final _ in _db.from('bookings').stream(primaryKey: ['id']).eq('client_id', _uid).skip(1)) {
      yield await myBookings();
    }
  }

  Future<Booking> getBooking(String id) => guard(() async {
        final row = await _db.from('bookings').select(Booking.select).eq('id', id).single();
        return Booking.fromJson(row);
      }, retries: 2);

  /// Suivi en temps réel : republie la réservation (avec noms) à chaque changement.
  Stream<Booking> watchBooking(String id) async* {
    yield await getBooking(id);
    await for (final _ in _db.from('bookings').stream(primaryKey: ['id']).eq('id', id).skip(1)) {
      yield await getBooking(id);
    }
  }

  Future<Booking> cancel(String bookingId, {String? reason}) => guard(() async {
        final res = await _db.rpc('cancel_booking', params: {'p_booking_id': bookingId, 'p_reason': reason});
        return Booking.fromJson(asJson(res));
      });

  Future<BookingContact> contact(String bookingId) => guard(() async {
        final res = await _db.rpc('get_booking_contact', params: {'p_booking_id': bookingId});
        final rows = res is List ? res : [res];
        return BookingContact.fromJson(asJson(rows.first));
      }, retries: 1);

  Future<BookingDriverInfo?> bookingDriver(String bookingId) => guard(() async {
        final res = await _db.rpc('get_booking_driver', params: {'p_booking_id': bookingId});
        final rows = res is List ? res : (res == null ? const [] : [res]);
        return rows.isEmpty ? null : BookingDriverInfo.fromJson(asJson(rows.first));
      }, retries: 1);

  Future<Review> submitReview(String bookingId, int rating, String? comment) => guard(() async {
        final res = await _db.rpc('submit_review', params: {
          'p_booking_id': bookingId,
          'p_rating': rating,
          'p_comment': comment,
        });
        return Review.fromJson(asJson(res));
      });

  Future<Review?> reviewForBooking(String bookingId) => guard(() async {
        final row = await _db.from('reviews').select().eq('booking_id', bookingId).maybeSingle();
        return row == null ? null : Review.fromJson(row);
      }, retries: 1);

  Future<void> fileComplaint({String? bookingId, required String text}) => guard(() async {
        await _db.rpc('file_complaint', params: {'p_booking_id': bookingId, 'p_text': text});
      });

  Future<List<Complaint>> myComplaints() => guard(() async {
        final rows = await _db.from('complaints').select().order('created_at', ascending: false).limit(50);
        return rows.map(Complaint.fromJson).toList();
      }, retries: 2);

  // ===== Chauffeur ================================================================
  Future<List<IncomingRequest>> incomingRequests() => guard(() async {
        final rows = await _db.from('driver_incoming_requests').select().order('created_at');
        return rows.map(IncomingRequest.fromJson).toList();
      }, retries: 2);

  /// Les demandes viennent d'une vue (non diffusable) : on écoute `booking_offers` et on relit la vue.
  Stream<List<IncomingRequest>> watchIncoming(String driverId) async* {
    yield await incomingRequests();
    await for (final _ in _db.from('booking_offers').stream(primaryKey: ['id']).eq('driver_id', driverId).skip(1)) {
      yield await incomingRequests();
    }
  }

  Future<List<Booking>> driverBookings(String driverId) => guard(() async {
        final rows = await _db
            .from('bookings')
            .select(Booking.select)
            .eq('driver_id', driverId)
            .order('scheduled_at', ascending: false)
            .limit(100);
        return rows.map(Booking.fromJson).toList();
      }, retries: 2);

  Stream<List<Booking>> watchDriverBookings(String driverId) async* {
    yield await driverBookings(driverId);
    await for (final _ in _db.from('bookings').stream(primaryKey: ['id']).eq('driver_id', driverId).skip(1)) {
      yield await driverBookings(driverId);
    }
  }

  Future<Booking> accept(String bookingId) => guard(() async {
        final res = await _db.rpc('accept_booking', params: {'p_booking_id': bookingId});
        return Booking.fromJson(asJson(res));
      });

  Future<void> reject(String bookingId) => guard(() async {
        await _db.rpc('reject_booking', params: {'p_booking_id': bookingId});
      });

  Future<Booking> updateStatus(String bookingId, BookingStatus status) => guard(() async {
        final res = await _db.rpc('update_booking_status', params: {
          'p_booking_id': bookingId,
          'p_new_status': status.db,
        });
        return Booking.fromJson(asJson(res));
      });
}
