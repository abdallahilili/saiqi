import 'enums.dart';
import 'json_utils.dart';

class Booking {
  const Booking({
    required this.id,
    required this.clientName,
    required this.serviceTypeId,
    required this.cityId,
    required this.pickupText,
    required this.scheduledAt,
    required this.passengers,
    required this.price,
    required this.status,
    required this.channel,
    required this.createdByType,
    required this.createdAt,
    this.clientId,
    this.clientPhone,
    this.driverId,
    this.dropoffText,
    this.notes,
    this.cancelReason,
    this.cancelledBy,
    this.acceptedAt,
    this.completedAt,
    this.expiresAt,
    this.serviceNameAr,
    this.serviceNameFr,
    this.cityNameAr,
    this.cityNameFr,
  });

  final String id;
  final String? clientId;
  final String clientName;

  /// Renseigné uniquement pour les admins et le client lui-même ; jamais pour un chauffeur avant acceptation.
  final String? clientPhone;
  final String? driverId;
  final String serviceTypeId;
  final String cityId;
  final String pickupText;
  final String? dropoffText;
  final DateTime scheduledAt;
  final int passengers;
  final String? notes;
  final int price;
  final BookingStatus status;
  final BookingChannel channel;
  final String createdByType;
  final String? cancelReason;
  final String? cancelledBy;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final String? serviceNameAr;
  final String? serviceNameFr;
  final String? cityNameAr;
  final String? cityNameFr;

  bool get createdByAdmin => createdByType == 'admin';
  String serviceName(String lang) => (lang == 'fr' ? serviceNameFr : serviceNameAr) ?? '';
  String cityName(String lang) => (lang == 'fr' ? cityNameFr : cityNameAr) ?? '';

  /// Colonnes + relations demandées à PostgREST (aucune colonne sensible n'est exclue : la RLS décide).
  static const select = '*, service_types(name_ar,name_fr), cities(name_ar,name_fr)';

  factory Booking.fromJson(Json j) {
    final st = firstJson(j['service_types']);
    final city = firstJson(j['cities']);
    return Booking(
      id: j['id'] as String,
      clientId: j['client_id'] as String?,
      clientName: (j['client_name'] ?? '') as String,
      clientPhone: j['client_phone'] as String?,
      driverId: j['driver_id'] as String?,
      serviceTypeId: j['service_type_id'] as String,
      cityId: j['city_id'] as String,
      pickupText: (j['pickup_text'] ?? '') as String,
      dropoffText: j['dropoff_text'] as String?,
      scheduledAt: asDateOr(j['scheduled_at'], DateTime.now()),
      passengers: asInt(j['passengers'], 1),
      notes: j['notes'] as String?,
      price: asInt(j['price']),
      status: enumFromDb(BookingStatus.values, j['status'], BookingStatus.pending),
      channel: enumFromDb(BookingChannel.values, j['channel'], BookingChannel.app),
      createdByType: (j['created_by_type'] ?? 'client') as String,
      cancelReason: j['cancel_reason'] as String?,
      cancelledBy: j['cancelled_by'] as String?,
      acceptedAt: asDate(j['accepted_at']),
      completedAt: asDate(j['completed_at']),
      expiresAt: asDate(j['expires_at']),
      createdAt: asDateOr(j['created_at'], DateTime.now()),
      serviceNameAr: st?['name_ar'] as String? ?? j['service_name_ar'] as String?,
      serviceNameFr: st?['name_fr'] as String? ?? j['service_name_fr'] as String?,
      cityNameAr: city?['name_ar'] as String? ?? j['city_name_ar'] as String?,
      cityNameFr: city?['name_fr'] as String? ?? j['city_name_fr'] as String?,
    );
  }
}

/// Demande entrante d'un chauffeur (vue `driver_incoming_requests`) — sans téléphone client.
class IncomingRequest {
  const IncomingRequest({
    required this.offerId,
    required this.bookingId,
    required this.clientName,
    required this.pickupText,
    required this.scheduledAt,
    required this.passengers,
    required this.price,
    required this.commissionRate,
    required this.commissionAmount,
    required this.channel,
    required this.createdAt,
    this.dropoffText,
    this.notes,
    this.expiresAt,
    this.serviceNameAr,
    this.serviceNameFr,
    this.cityNameAr,
    this.cityNameFr,
  });

  final String offerId;
  final String bookingId;
  final String clientName;
  final String pickupText;
  final String? dropoffText;
  final DateTime scheduledAt;
  final int passengers;
  final String? notes;
  final int price;
  final double commissionRate;
  final int commissionAmount;
  final BookingChannel channel;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final String? serviceNameAr;
  final String? serviceNameFr;
  final String? cityNameAr;
  final String? cityNameFr;

  String serviceName(String lang) => (lang == 'fr' ? serviceNameFr : serviceNameAr) ?? '';
  String cityName(String lang) => (lang == 'fr' ? cityNameFr : cityNameAr) ?? '';

  factory IncomingRequest.fromJson(Json j) => IncomingRequest(
        offerId: j['offer_id'] as String,
        bookingId: j['booking_id'] as String,
        clientName: (j['client_name'] ?? '') as String,
        pickupText: (j['pickup_text'] ?? '') as String,
        dropoffText: j['dropoff_text'] as String?,
        scheduledAt: asDateOr(j['scheduled_at'], DateTime.now()),
        passengers: asInt(j['passengers'], 1),
        notes: j['notes'] as String?,
        price: asInt(j['price']),
        commissionRate: asDouble(j['commission_rate']),
        commissionAmount: asInt(j['commission_amount']),
        channel: enumFromDb(BookingChannel.values, j['channel'], BookingChannel.app),
        expiresAt: asDate(j['expires_at']),
        createdAt: asDateOr(j['created_at'], DateTime.now()),
        serviceNameAr: j['service_name_ar'] as String?,
        serviceNameFr: j['service_name_fr'] as String?,
        cityNameAr: j['city_name_ar'] as String?,
        cityNameFr: j['city_name_fr'] as String?,
      );
}

class BookingContact {
  const BookingContact({required this.fullName, required this.phone});
  final String? fullName;
  final String phone;

  factory BookingContact.fromJson(Json j) =>
      BookingContact(fullName: j['full_name'] as String?, phone: (j['phone'] ?? '') as String);
}

/// Chauffeur d'une réservation, vu par le client (RPC `get_booking_driver`) — sans téléphone.
class BookingDriverInfo {
  const BookingDriverInfo({
    required this.driverId,
    required this.ratingAvg,
    required this.ratingCount,
    this.fullName,
    this.avatarUrl,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePlate,
    this.vehiclePhoto,
  });
  final String driverId;
  final String? fullName;
  final String? avatarUrl;
  final double ratingAvg;
  final int ratingCount;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehiclePlate;
  final String? vehiclePhoto;

  String get vehicleTitle => [vehicleBrand, vehicleModel].whereType<String>().join(' ');

  factory BookingDriverInfo.fromJson(Json j) => BookingDriverInfo(
        driverId: j['driver_id'] as String,
        fullName: j['full_name'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        ratingAvg: asDouble(j['rating_avg']),
        ratingCount: asInt(j['rating_count']),
        vehicleBrand: j['vehicle_brand'] as String?,
        vehicleModel: j['vehicle_model'] as String?,
        vehicleColor: j['vehicle_color'] as String?,
        vehiclePlate: j['vehicle_plate'] as String?,
        vehiclePhoto: j['vehicle_photo'] as String?,
      );
}

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.createdAt,
    this.bookingId,
    this.driverId,
    this.comment,
    this.reviewerName,
    this.isHidden = false,
    this.driverName,
  });
  final String id;
  final String? bookingId;
  final String? driverId;
  final int rating;
  final String? comment;
  final String? reviewerName;
  final bool isHidden;
  final String? driverName;
  final DateTime createdAt;

  factory Review.fromJson(Json j) => Review(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String?,
        driverId: j['driver_id'] as String?,
        rating: asInt(j['rating']),
        comment: j['comment'] as String?,
        reviewerName: j['reviewer_name'] as String?,
        isHidden: (j['is_hidden'] ?? false) as bool,
        createdAt: asDateOr(j['created_at'], DateTime.now()),
      );
}

class Complaint {
  const Complaint({
    required this.id,
    required this.authorId,
    required this.text,
    required this.status,
    required this.createdAt,
    this.bookingId,
    this.againstId,
    this.resolution,
    this.authorName,
    this.againstName,
  });
  final String id;
  final String? bookingId;
  final String authorId;
  final String? againstId;
  final String text;
  final ComplaintStatus status;
  final String? resolution;
  final DateTime createdAt;
  final String? authorName;
  final String? againstName;

  factory Complaint.fromJson(Json j) {
    final author = firstJson(j['author']);
    final against = firstJson(j['against']);
    return Complaint(
      id: j['id'] as String,
      bookingId: j['booking_id'] as String?,
      authorId: j['author_id'] as String,
      againstId: j['against_id'] as String?,
      text: (j['text'] ?? '') as String,
      status: enumFromDb(ComplaintStatus.values, j['status'], ComplaintStatus.open),
      resolution: j['resolution'] as String?,
      createdAt: asDateOr(j['created_at'], DateTime.now()),
      authorName: author?['full_name'] as String? ?? author?['phone'] as String?,
      againstName: against?['full_name'] as String? ?? against?['phone'] as String?,
    );
  }
}
