import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';
import '../models/misc_models.dart';

class NotificationRepository {
  NotificationRepository(this._db);
  final SupabaseClient _db;

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const AppException('not_authenticated');
    return id;
  }

  /// Boîte de réception en temps réel (Realtime), plus récentes d'abord.
  Stream<List<AppNotification>> watch({int limit = 100}) {
    return _db
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .limit(limit)
        .map((rows) => rows.map(AppNotification.fromJson).toList());
  }

  Future<void> markRead(String id) => guard(() async {
        await _db.from('notifications').update({'read_at': DateTime.now().toUtc().toIso8601String()}).eq('id', id);
      });

  Future<void> markAllRead() => guard(() async {
        await _db
            .from('notifications')
            .update({'read_at': DateTime.now().toUtc().toIso8601String()})
            .eq('user_id', _uid)
            .isFilter('read_at', null);
      });

  Future<void> delete(String id) => guard(() async {
        await _db.from('notifications').delete().eq('id', id);
      });
}
