import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:saiqi_admin/app/providers.dart';
import 'package:saiqi_admin/app/router.dart';
import 'package:saiqi_admin/core/core.dart';
import 'package:saiqi_admin/features/dashboard/presentation/dashboard_screen.dart';

import '../helpers.dart';

class _FakeProfile extends ProfileNotifier {
  _FakeProfile(this._profile);
  final Profile _profile;

  @override
  Future<Profile?> build() async => _profile;
}

Profile _admin(AdminRole role) => Profile(
      id: 'a1',
      role: UserRole.admin,
      phone: '+22220000001',
      language: 'fr',
      status: AccountStatus.active,
      fullName: 'Admin SAIQI',
      adminRole: role,
    );

List<Override> _overrides(AdminRole role) => [
      profileProvider.overrideWith(() => _FakeProfile(_admin(role))),
      unreadNotificationsProvider.overrideWith((ref) => Stream.value(0)),
      dashboardStatsProvider.overrideWith(
        (ref) async => const AdminStats({
          'pending_drivers': 3,
          'new_drivers_7d': 5,
          'approved_drivers': 12,
          'clients': 40,
          'bookings_today': 7,
          'pending_bookings': 2,
          'commissions_today': 450,
          'commissions_total': 12000,
          'open_complaints': 1,
          'pending_topups': 4,
        }),
      ),
    ];

void main() {
  testWidgets('tableau de bord : KPI et action « Créer une demande » pour un support', (tester) async {
    await pumpScreen(tester, const DashboardScreen(), overrides: _overrides(AdminRole.support));
    await tester.pumpAndSettle();

    expect(find.text('Dossiers en attente'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Réservations du jour'), findsOneWidget);
    expect(find.textContaining('450 MRU'), findsWidgets);
    expect(find.text('Créer une demande'), findsOneWidget);
  });

  testWidgets('un validateur ne peut pas créer de demande', (tester) async {
    await pumpScreen(tester, const DashboardScreen(), overrides: _overrides(AdminRole.validator));
    await tester.pumpAndSettle();
    expect(find.text('Créer une demande'), findsNothing);
  });

  testWidgets('interface arabe du tableau de bord (RTL)', (tester) async {
    await pumpScreen(tester, const DashboardScreen(), overrides: _overrides(AdminRole.superAdmin), lang: 'ar');
    await tester.pumpAndSettle();
    expect(find.text('لوحة التحكم'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(DashboardScreen))), TextDirection.rtl);
  });

  test('droits par rôle admin', () {
    const sup = Perms(AdminRole.superAdmin);
    const val = Perms(AdminRole.validator);
    const sp = Perms(AdminRole.support);
    expect(sup.canAdjustWallet && sup.canConfigure && sup.canValidateDrivers && sup.canManageBookings, isTrue);
    expect(val.canValidateDrivers, isTrue);
    expect(val.canManageBookings || val.canReviewTopups || val.canAdjustWallet || val.canConfigure, isFalse);
    expect(sp.canManageBookings && sp.canReviewTopups && sp.canHandleComplaints, isTrue);
    expect(sp.canValidateDrivers || sp.canAdjustWallet || sp.canConfigure, isFalse);
  });

  test('onglets autorisés selon le rôle', () {
    expect(allowedBranches(const Perms(AdminRole.superAdmin)), [0, 1, 2, 3, 4]);
    expect(allowedBranches(const Perms(AdminRole.validator)), [0, 1, 4]);
    expect(allowedBranches(const Perms(AdminRole.support)), [0, 2, 3, 4]);
  });
}
