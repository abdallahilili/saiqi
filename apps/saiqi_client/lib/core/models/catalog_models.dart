import 'enums.dart';
import 'json_utils.dart';

class Profile {
  const Profile({
    required this.id,
    required this.role,
    required this.phone,
    required this.language,
    required this.status,
    this.fullName,
    this.avatarUrl,
    this.adminRole,
    this.createdAt,
  });

  final String id;
  final UserRole role;
  final String? fullName;
  final String phone;
  final String? avatarUrl;
  final String language;
  final AccountStatus status;
  final AdminRole? adminRole;
  final DateTime? createdAt;

  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : phone;

  factory Profile.fromJson(Json j) => Profile(
        id: j['id'] as String,
        role: enumFromDb(UserRole.values, j['role'], UserRole.client),
        fullName: j['full_name'] as String?,
        phone: (j['phone'] ?? '') as String,
        avatarUrl: j['avatar_url'] as String?,
        language: (j['language'] ?? 'ar') as String,
        status: enumFromDb(AccountStatus.values, j['status'], AccountStatus.active),
        adminRole: j['admin_role'] == null ? null : enumFromDb(AdminRole.values, j['admin_role'], AdminRole.support),
        createdAt: asDate(j['created_at']),
      );

  Json toJson() => {
        'id': id,
        'role': role.db,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'language': language,
        'status': status.db,
        'admin_role': adminRole?.db,
      };
}

class City {
  const City({required this.id, required this.nameAr, required this.nameFr, this.isActive = true});
  final String id;
  final String nameAr;
  final String nameFr;
  final bool isActive;

  String name(String lang) => lang == 'fr' ? nameFr : nameAr;

  factory City.fromJson(Json j) => City(
        id: j['id'] as String,
        nameAr: (j['name_ar'] ?? '') as String,
        nameFr: (j['name_fr'] ?? '') as String,
        isActive: (j['is_active'] ?? true) as bool,
      );

  Json toJson() => {'id': id, 'name_ar': nameAr, 'name_fr': nameFr, 'is_active': isActive};
}

class ServiceType {
  const ServiceType({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.icon,
    this.isActive = true,
  });
  final String id;
  final String nameAr;
  final String nameFr;
  final String icon;
  final bool isActive;

  String name(String lang) => lang == 'fr' ? nameFr : nameAr;

  factory ServiceType.fromJson(Json j) => ServiceType(
        id: j['id'] as String,
        nameAr: (j['name_ar'] ?? '') as String,
        nameFr: (j['name_fr'] ?? '') as String,
        icon: (j['icon'] ?? 'directions_car') as String,
        isActive: (j['is_active'] ?? true) as bool,
      );

  Json toJson() => {'id': id, 'name_ar': nameAr, 'name_fr': nameFr, 'icon': icon, 'is_active': isActive};
}

/// Réglages `app_settings` (clé -> valeur JSON) avec accès typé.
class AppSettings {
  const AppSettings(this.values);
  final Map<String, dynamic> values;

  static const empty = AppSettings({});

  double get defaultCommissionRate => asDouble(values['default_commission_rate'], 0.10);
  int get responseTimeoutMinutes => asInt(values['response_timeout_minutes'], 10);
  int get lowBalanceThreshold => asInt(values['low_balance_threshold'], 100);
  int get minTopupAmount => asInt(values['min_topup_amount'], 100);
  String get supportPhone => (values['support_phone'] ?? '').toString();
  String get supportWhatsapp => (values['support_whatsapp'] ?? '').toString();

  List<TopupMethod> get topupMethods {
    final raw = values['topup_methods'];
    if (raw is! List) return const [];
    return raw.map((e) => TopupMethod.fromJson(asJson(e))).toList();
  }

  Json toJson() => values;
}

class TopupMethod {
  const TopupMethod({required this.id, required this.nameAr, required this.nameFr, this.account = ''});
  final String id;
  final String nameAr;
  final String nameFr;
  final String account;

  String name(String lang) => lang == 'fr' ? nameFr : nameAr;

  factory TopupMethod.fromJson(Json j) => TopupMethod(
        id: (j['id'] ?? '').toString(),
        nameAr: (j['name_ar'] ?? '').toString(),
        nameFr: (j['name_fr'] ?? '').toString(),
        account: (j['account'] ?? '').toString(),
      );

  Json toJson() => {'id': id, 'name_ar': nameAr, 'name_fr': nameFr, 'account': account};
}

class CommissionRate {
  const CommissionRate({required this.id, required this.rate, this.serviceTypeId, this.cityId});
  final String id;
  final double rate;
  final String? serviceTypeId;
  final String? cityId;

  factory CommissionRate.fromJson(Json j) => CommissionRate(
        id: j['id'] as String,
        rate: asDouble(j['rate']),
        serviceTypeId: j['service_type_id'] as String?,
        cityId: j['city_id'] as String?,
      );
}
