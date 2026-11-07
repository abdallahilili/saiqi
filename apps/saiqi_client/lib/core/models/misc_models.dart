import 'enums.dart';
import 'json_utils.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.readAt,
  });
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Json j) => AppNotification(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        data: asJson(j['data']),
        readAt: asDate(j['read_at']),
        createdAt: asDateOr(j['created_at'], DateTime.now()),
      );
}

class AuditLog {
  const AuditLog({
    required this.id,
    required this.action,
    required this.entity,
    required this.payload,
    required this.createdAt,
    this.actorName,
    this.entityId,
  });
  final String id;
  final String action;
  final String entity;
  final String? entityId;
  final Map<String, dynamic> payload;
  final String? actorName;
  final DateTime createdAt;

  factory AuditLog.fromJson(Json j) {
    final actor = firstJson(j['actor']);
    return AuditLog(
      id: j['id'] as String,
      action: (j['action'] ?? '') as String,
      entity: (j['entity'] ?? '') as String,
      entityId: j['entity_id'] as String?,
      payload: asJson(j['payload']),
      actorName: actor?['full_name'] as String? ?? actor?['phone'] as String?,
      createdAt: asDateOr(j['created_at'], DateTime.now()),
    );
  }
}

class Announcement {
  const Announcement({
    required this.id,
    required this.audience,
    required this.title,
    required this.body,
    required this.recipientsCount,
    required this.createdAt,
  });
  final String id;
  final String audience;
  final String title;
  final String body;
  final int recipientsCount;
  final DateTime createdAt;

  factory Announcement.fromJson(Json j) => Announcement(
        id: j['id'] as String,
        audience: (j['audience'] ?? 'all') as String,
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        recipientsCount: asInt(j['recipients_count']),
        createdAt: asDateOr(j['created_at'], DateTime.now()),
      );
}

class AdminStats {
  const AdminStats(this.v);
  final Map<String, dynamic> v;

  int get pendingDrivers => asInt(v['pending_drivers']);
  int get newDrivers7d => asInt(v['new_drivers_7d']);
  int get approvedDrivers => asInt(v['approved_drivers']);
  int get clients => asInt(v['clients']);
  int get bookingsToday => asInt(v['bookings_today']);
  int get pendingBookings => asInt(v['pending_bookings']);
  int get commissionsToday => asInt(v['commissions_today']);
  int get commissionsTotal => asInt(v['commissions_total']);
  int get openComplaints => asInt(v['open_complaints']);
  int get pendingTopups => asInt(v['pending_topups']);
}

/// Membre de l'équipe admin / client listé côté admin.
class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.role,
    required this.phone,
    required this.status,
    this.fullName,
    this.adminRole,
    this.createdAt,
  });
  final String id;
  final UserRole role;
  final String phone;
  final String? fullName;
  final AccountStatus status;
  final AdminRole? adminRole;
  final DateTime? createdAt;

  String get displayName => (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : phone;

  factory ProfileSummary.fromJson(Json j) => ProfileSummary(
        id: j['id'] as String,
        role: enumFromDb(UserRole.values, j['role'], UserRole.client),
        phone: (j['phone'] ?? '') as String,
        fullName: j['full_name'] as String?,
        status: enumFromDb(AccountStatus.values, j['status'], AccountStatus.active),
        adminRole: j['admin_role'] == null ? null : enumFromDb(AdminRole.values, j['admin_role'], AdminRole.support),
        createdAt: asDate(j['created_at']),
      );
}
