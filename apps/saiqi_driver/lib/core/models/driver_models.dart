import 'enums.dart';
import 'json_utils.dart';

class Driver {
  const Driver({
    required this.id,
    required this.profileId,
    required this.status,
    required this.isAvailable,
    required this.ratingAvg,
    required this.ratingCount,
    required this.completedCount,
    this.cityId,
    this.rejectionReason,
    this.bio,
    this.yearsExperience,
    this.submittedAt,
    this.createdAt,
  });

  final String id;
  final String profileId;
  final String? cityId;
  final DriverStatus status;
  final String? rejectionReason;
  final bool isAvailable;
  final String? bio;
  final int? yearsExperience;
  final double ratingAvg;
  final int ratingCount;
  final int completedCount;
  final DateTime? submittedAt;
  final DateTime? createdAt;

  bool get isApproved => status == DriverStatus.approved;

  factory Driver.fromJson(Json j) => Driver(
        id: j['id'] as String,
        profileId: j['profile_id'] as String,
        cityId: j['city_id'] as String?,
        status: enumFromDb(DriverStatus.values, j['status'], DriverStatus.draft),
        rejectionReason: j['rejection_reason'] as String?,
        isAvailable: (j['is_available'] ?? false) as bool,
        bio: j['bio'] as String?,
        yearsExperience: j['years_experience'] == null ? null : asInt(j['years_experience']),
        ratingAvg: asDouble(j['rating_avg']),
        ratingCount: asInt(j['rating_count']),
        completedCount: asInt(j['completed_count']),
        submittedAt: asDate(j['submitted_at']),
        createdAt: asDate(j['created_at']),
      );
}

class Vehicle {
  const Vehicle({
    required this.driverId,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.seats,
    required this.plate,
    this.id,
    this.year,
    this.color,
    this.photoPaths = const [],
  });

  final String? id;
  final String driverId;
  final String vehicleType;
  final String brand;
  final String model;
  final int? year;
  final String? color;
  final int seats;
  final String plate;
  final List<String> photoPaths;

  String get title => '$brand $model';

  factory Vehicle.fromJson(Json j) => Vehicle(
        id: j['id'] as String?,
        driverId: j['driver_id'] as String,
        vehicleType: (j['vehicle_type'] ?? 'sedan') as String,
        brand: (j['brand'] ?? '') as String,
        model: (j['model'] ?? '') as String,
        year: j['year'] == null ? null : asInt(j['year']),
        color: j['color'] as String?,
        seats: asInt(j['seats'], 4),
        plate: (j['plate'] ?? '') as String,
        photoPaths: asStringList(j['photo_paths']),
      );

  Json toJson() => {
        'driver_id': driverId,
        'vehicle_type': vehicleType,
        'brand': brand,
        'model': model,
        'year': year,
        'color': color,
        'seats': seats,
        'plate': plate,
        'photo_paths': photoPaths,
      };

  Vehicle copyWith({List<String>? photoPaths}) => Vehicle(
        id: id,
        driverId: driverId,
        vehicleType: vehicleType,
        brand: brand,
        model: model,
        year: year,
        color: color,
        seats: seats,
        plate: plate,
        photoPaths: photoPaths ?? this.photoPaths,
      );
}

class DriverService {
  const DriverService({
    required this.driverId,
    required this.serviceTypeId,
    required this.cityIds,
    required this.price,
    required this.priceUnit,
    this.id,
    this.isActive = true,
  });

  final String? id;
  final String driverId;
  final String serviceTypeId;
  final List<String> cityIds;
  final int price;
  final PriceUnit priceUnit;
  final bool isActive;

  factory DriverService.fromJson(Json j) => DriverService(
        id: j['id'] as String?,
        driverId: j['driver_id'] as String,
        serviceTypeId: j['service_type_id'] as String,
        cityIds: asStringList(j['city_ids']),
        price: asInt(j['price']),
        priceUnit: enumFromDb(PriceUnit.values, j['price_unit'], PriceUnit.perTrip),
        isActive: (j['is_active'] ?? true) as bool,
      );

  Json toJson() => {
        'driver_id': driverId,
        'service_type_id': serviceTypeId,
        'city_ids': cityIds,
        'price': price,
        'price_unit': priceUnit.db,
        'is_active': isActive,
      };
}

class DriverAvailability {
  const DriverAvailability({required this.weekday, required this.start, required this.end, this.id});
  final String? id;

  /// ISO : 1 = lundi … 7 = dimanche
  final int weekday;

  /// Format `HH:mm`
  final String start;
  final String end;

  factory DriverAvailability.fromJson(Json j) => DriverAvailability(
        id: j['id'] as String?,
        weekday: asInt(j['weekday']),
        start: _hhmm((j['start_time'] ?? '08:00').toString()),
        end: _hhmm((j['end_time'] ?? '18:00').toString()),
      );

  static String _hhmm(String t) => t.length >= 5 ? t.substring(0, 5) : t;
}

class DriverDocument {
  const DriverDocument({
    required this.id,
    required this.driverId,
    required this.type,
    required this.filePath,
    required this.status,
    this.rejectionReason,
  });
  final String id;
  final String driverId;
  final DocumentType type;
  final String filePath;
  final DocumentStatus status;
  final String? rejectionReason;

  factory DriverDocument.fromJson(Json j) => DriverDocument(
        id: j['id'] as String,
        driverId: j['driver_id'] as String,
        type: enumFromDb(DocumentType.values, j['type'], DocumentType.idCard),
        filePath: (j['file_path'] ?? '') as String,
        status: enumFromDb(DocumentStatus.values, j['status'], DocumentStatus.pending),
        rejectionReason: j['rejection_reason'] as String?,
      );
}

/// Chauffeur visible publiquement (résultat de `search_drivers` / vue `public_drivers`). Jamais de téléphone.
class PublicDriver {
  const PublicDriver({
    required this.driverId,
    required this.ratingAvg,
    required this.ratingCount,
    required this.completedCount,
    required this.isAvailable,
    this.fullName,
    this.avatarUrl,
    this.cityId,
    this.yearsExperience,
    this.bio,
    this.vehicleType,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleColor,
    this.seats,
    this.vehiclePhotos = const [],
    this.serviceTypeId,
    this.price,
    this.priceUnit,
  });

  final String driverId;
  final String? fullName;
  final String? avatarUrl;
  final String? cityId;
  final double ratingAvg;
  final int ratingCount;
  final int completedCount;
  final bool isAvailable;
  final int? yearsExperience;
  final String? bio;
  final String? vehicleType;
  final String? vehicleBrand;
  final String? vehicleModel;
  final int? vehicleYear;
  final String? vehicleColor;
  final int? seats;
  final List<String> vehiclePhotos;
  final String? serviceTypeId;
  final int? price;
  final PriceUnit? priceUnit;

  String get vehicleTitle => [vehicleBrand, vehicleModel].whereType<String>().join(' ');

  factory PublicDriver.fromJson(Json j) {
    final photos = asStringList(j['vehicle_photos']);
    final single = j['vehicle_photo'] as String?;
    return PublicDriver(
      driverId: j['driver_id'] as String,
      fullName: j['full_name'] as String?,
      avatarUrl: j['avatar_url'] as String?,
      cityId: j['city_id'] as String?,
      ratingAvg: asDouble(j['rating_avg']),
      ratingCount: asInt(j['rating_count']),
      completedCount: asInt(j['completed_count']),
      isAvailable: (j['is_available'] ?? false) as bool,
      yearsExperience: j['years_experience'] == null ? null : asInt(j['years_experience']),
      bio: j['bio'] as String?,
      vehicleType: j['vehicle_type'] as String?,
      vehicleBrand: (j['vehicle_brand'] ?? j['brand']) as String?,
      vehicleModel: (j['vehicle_model'] ?? j['model']) as String?,
      vehicleYear: j['vehicle_year'] == null ? null : asInt(j['vehicle_year']),
      vehicleColor: j['vehicle_color'] as String?,
      seats: j['seats'] == null ? null : asInt(j['seats']),
      vehiclePhotos: photos.isNotEmpty ? photos : (single == null ? const [] : [single]),
      serviceTypeId: j['service_type_id'] as String?,
      price: j['price'] == null ? null : asInt(j['price']),
      priceUnit: j['price_unit'] == null ? null : enumFromDb(PriceUnit.values, j['price_unit'], PriceUnit.perTrip),
    );
  }
}

/// Service d'un chauffeur visible publiquement (vue `public_driver_services`).
class PublicDriverService {
  const PublicDriverService({
    required this.driverId,
    required this.serviceTypeId,
    required this.cityIds,
    required this.price,
    required this.priceUnit,
  });
  final String driverId;
  final String serviceTypeId;
  final List<String> cityIds;
  final int price;
  final PriceUnit priceUnit;

  factory PublicDriverService.fromJson(Json j) => PublicDriverService(
        driverId: j['driver_id'] as String,
        serviceTypeId: j['service_type_id'] as String,
        cityIds: asStringList(j['city_ids']),
        price: asInt(j['price']),
        priceUnit: enumFromDb(PriceUnit.values, j['price_unit'], PriceUnit.perTrip),
      );
}

class DriverStats {
  const DriverStats({
    required this.completedCount,
    required this.revenueGross,
    required this.commissionsPaid,
    required this.ratingAvg,
    required this.ratingCount,
    required this.pendingRequests,
    required this.upcomingCount,
  });
  final int completedCount;
  final int revenueGross;
  final int commissionsPaid;
  final double ratingAvg;
  final int ratingCount;
  final int pendingRequests;
  final int upcomingCount;

  int get revenueNet => revenueGross - commissionsPaid;

  factory DriverStats.fromJson(Json j) => DriverStats(
        completedCount: asInt(j['completed_count']),
        revenueGross: asInt(j['revenue_gross']),
        commissionsPaid: asInt(j['commissions_paid']),
        ratingAvg: asDouble(j['rating_avg']),
        ratingCount: asInt(j['rating_count']),
        pendingRequests: asInt(j['pending_requests']),
        upcomingCount: asInt(j['upcoming_count']),
      );
}

/// Chauffeur vu par l'admin : driver + profil + ville + solde.
class AdminDriver {
  const AdminDriver({
    required this.driver,
    required this.fullName,
    required this.phone,
    required this.accountStatus,
    this.avatarUrl,
    this.cityNameAr,
    this.cityNameFr,
    this.balance,
  });
  final Driver driver;
  final String? fullName;
  final String phone;
  final AccountStatus accountStatus;
  final String? avatarUrl;
  final String? cityNameAr;
  final String? cityNameFr;
  final int? balance;

  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : phone;
  String? cityName(String lang) => lang == 'fr' ? cityNameFr : cityNameAr;

  factory AdminDriver.fromJson(Json j) {
    final profile = firstJson(j['profiles']) ?? {};
    final city = firstJson(j['cities']);
    final wallet = firstJson(j['wallets']);
    return AdminDriver(
      driver: Driver.fromJson(j),
      fullName: profile['full_name'] as String?,
      phone: (profile['phone'] ?? '') as String,
      avatarUrl: profile['avatar_url'] as String?,
      accountStatus: enumFromDb(AccountStatus.values, profile['status'], AccountStatus.active),
      cityNameAr: city?['name_ar'] as String?,
      cityNameFr: city?['name_fr'] as String?,
      balance: wallet == null ? null : asInt(wallet['balance']),
    );
  }
}
