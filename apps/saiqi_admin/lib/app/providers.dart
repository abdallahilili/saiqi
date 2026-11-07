import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/core.dart';

/// Rôle admin du compte connecté (super_admin / validator / support).
final adminRoleProvider = Provider<AdminRole?>((ref) => ref.watch(profileProvider).value?.adminRole);

/// Droits par rôle : l'interface masque ce qui est interdit, le serveur (RLS + admin_role) l'impose réellement.
class Perms {
  const Perms(this.role);
  final AdminRole? role;

  bool get isSuper => role == AdminRole.superAdmin;
  bool get canValidateDrivers => isSuper || role == AdminRole.validator;
  bool get canManageBookings => isSuper || role == AdminRole.support;
  bool get canReviewTopups => isSuper || role == AdminRole.support;
  bool get canAdjustWallet => isSuper;
  bool get canManageClients => isSuper || role == AdminRole.support;
  bool get canHandleComplaints => isSuper || role == AdminRole.support;
  bool get canSendAnnouncements => isSuper || role == AdminRole.support;
  bool get canConfigure => isSuper; // commissions, réglages, catalogues, équipe, audit
}

final permsProvider = Provider<Perms>((ref) => Perms(ref.watch(adminRoleProvider)));

/// Incrémenté à chaque changement Realtime sur les tables suivies : les listes se rechargent sans geste.
final adminLiveTickProvider = StreamProvider<int>((ref) {
  final client = ref.watch(supabaseProvider);
  final controller = StreamController<int>();
  var n = 0;
  Timer? debounce;
  void bump() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 400), () {
      if (!controller.isClosed) controller.add(++n);
    });
  }

  final channel = client.channel('admin-live');
  for (final table in const ['drivers', 'driver_documents', 'bookings', 'topup_requests', 'complaints', 'reviews']) {
    channel.onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: table, callback: (_) => bump());
  }
  channel.subscribe();
  controller.add(0);

  ref.onDispose(() {
    debounce?.cancel();
    client.removeChannel(channel);
    controller.close();
  });
  return controller.stream;
});

// ---- tableau de bord ----------------------------------------------------------------
final dashboardStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).dashboardStats();
});

// ---- chauffeurs -----------------------------------------------------------------------
final adminDriversProvider = FutureProvider.autoDispose.family<List<AdminDriver>, DriverStatus?>((ref, status) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).listDrivers(status: status);
});

final adminDriverProvider = FutureProvider.autoDispose.family<AdminDriver, String>((ref, id) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).getDriver(id);
});

final adminDriverDocsProvider = FutureProvider.autoDispose.family<List<DriverDocument>, String>((ref, id) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).driverDocuments(id);
});

final adminDriverVehicleProvider = FutureProvider.autoDispose.family<Vehicle?, String>(
  (ref, id) => ref.watch(adminRepositoryProvider).driverVehicle(id),
);

final adminDriverServicesProvider = FutureProvider.autoDispose.family<List<DriverService>, String>(
  (ref, id) => ref.watch(adminRepositoryProvider).driverServices(id),
);
