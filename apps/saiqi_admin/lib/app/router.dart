import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import '../features/bookings/presentation/booking_detail_screen.dart';
import '../features/bookings/presentation/bookings_screen.dart';
import '../features/bookings/presentation/create_request_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/commissions/presentation/commissions_screen.dart';
import '../features/complaints/presentation/complaints_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/drivers/presentation/driver_detail_screen.dart';
import '../features/drivers/presentation/drivers_screen.dart';
import '../features/system/presentation/announcements_screen.dart';
import '../features/system/presentation/audit_screen.dart';
import '../features/system/presentation/more_screen.dart';
import '../features/users/presentation/clients_screen.dart';
import '../features/users/presentation/team_screen.dart';
import '../features/wallets/presentation/driver_wallet_screen.dart';
import '../features/wallets/presentation/wallets_screen.dart';
import 'providers.dart';

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(profileProvider, (_, _) => notifyListeners());
    ref.listen(languageChosenProvider, (_, _) => notifyListeners());
  }
}

/// Onglets de la barre de navigation (index de branche) autorisés selon le rôle.
List<int> allowedBranches(Perms p) => [
      0, // tableau de bord
      if (p.canValidateDrivers) 1,
      if (p.canManageBookings) 2,
      if (p.canReviewTopups) 3,
      4, // plus
    ];

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    if (!ref.read(languageChosenProvider)) return loc == '/welcome' ? null : '/welcome';

    final profile = ref.read(profileProvider);
    if (!profile.hasValue) return profile.hasError ? '/login' : (loc == '/splash' ? null : '/splash');
    final p = profile.requireValue;
    if (p == null) return loc == '/login' ? null : '/login';

    final perms = Perms(p.adminRole);
    if (loc == '/splash' || loc == '/login' || loc == '/welcome') return '/dashboard';

    bool denied() {
      if (loc.startsWith('/drivers') || loc.startsWith('/driver/')) return !perms.canValidateDrivers && !perms.canManageBookings;
      if (loc.startsWith('/bookings') || loc.startsWith('/booking/')) return !perms.canManageBookings;
      if (loc.startsWith('/wallets') || loc.startsWith('/wallet/')) return !perms.canReviewTopups && !perms.canAdjustWallet;
      if (loc.startsWith('/commissions') || loc.startsWith('/catalog') || loc.startsWith('/team') || loc.startsWith('/audit')) return !perms.canConfigure;
      if (loc.startsWith('/complaints') || loc.startsWith('/reviews')) return !perms.canHandleComplaints;
      if (loc.startsWith('/clients')) return !perms.canManageClients;
      if (loc.startsWith('/announcements')) return !perms.canSendAnnouncements;
      return false;
    }

    return denied() ? '/dashboard' : null;
  }

  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashView()),
      GoRoute(
        path: '/welcome',
        builder: (context, _) => LanguageWelcomeScreen(subtitle: context.l10n.adminBadge, onContinue: () {}),
      ),
      // Pas d'inscription publique : seuls les comptes admin existants peuvent se connecter.
      GoRoute(path: '/login', builder: (context, _) => LoginScreen(roleBadge: context.l10n.adminBadge)),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _AdminShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/drivers', builder: (_, _) => const DriversScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/wallets', builder: (_, _) => const WalletsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())]),
        ],
      ),

      GoRoute(path: '/driver/:id', parentNavigatorKey: rootKey, builder: (_, s) => DriverDetailScreen(driverId: s.pathParameters['id']!)),
      GoRoute(path: '/booking/new', parentNavigatorKey: rootKey, builder: (_, _) => const CreateRequestScreen()),
      GoRoute(path: '/booking/:id', parentNavigatorKey: rootKey, builder: (_, s) => BookingDetailScreen(bookingId: s.pathParameters['id']!)),
      GoRoute(path: '/wallet/driver/:id', parentNavigatorKey: rootKey, builder: (_, s) => DriverWalletScreen(driverId: s.pathParameters['id']!)),
      GoRoute(path: '/commissions', parentNavigatorKey: rootKey, builder: (_, _) => const CommissionsScreen()),
      GoRoute(path: '/complaints', parentNavigatorKey: rootKey, builder: (_, _) => const ComplaintsScreen()),
      GoRoute(path: '/reviews', parentNavigatorKey: rootKey, builder: (_, _) => const ReviewsModerationScreen()),
      GoRoute(path: '/clients', parentNavigatorKey: rootKey, builder: (_, _) => const ClientsScreen()),
      GoRoute(path: '/catalog', parentNavigatorKey: rootKey, builder: (_, _) => const CatalogScreen()),
      GoRoute(path: '/team', parentNavigatorKey: rootKey, builder: (_, _) => const TeamScreen()),
      GoRoute(path: '/audit', parentNavigatorKey: rootKey, builder: (_, _) => const AuditScreen()),
      GoRoute(path: '/announcements', parentNavigatorKey: rootKey, builder: (_, _) => const AnnouncementsScreen()),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (context, _) => NotificationsScreen(onOpen: (ctx, data) => openFromNotification(ctx, data)),
      ),
    ],
  );
});

/// Ouvre l'écran concerné à partir de `data` d'une notification.
void openFromNotification(BuildContext context, Map<String, dynamic> data) {
  final router = GoRouter.of(context);
  final bookingId = data['booking_id'] as String?;
  final driverId = data['driver_id'] as String?;
  switch (data['screen']) {
    case 'booking':
      if (bookingId != null) router.push('/booking/$bookingId');
    case 'driver':
      if (driverId != null) router.push('/driver/$driverId');
    case 'topup':
      router.go('/wallets');
    case 'complaint':
      router.push('/complaints');
  }
}

class _AdminShell extends ConsumerWidget {
  const _AdminShell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final perms = ref.watch(permsProvider);
    final stats = ref.watch(dashboardStatsProvider).value;
    final branches = allowedBranches(perms);
    final selected = branches.indexOf(shell.currentIndex).clamp(0, branches.length - 1);

    NavigationDestination dest(int branch) {
      switch (branch) {
        case 0:
          return NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard_rounded), label: l.dashboard);
        case 1:
          final n = stats?.pendingDrivers ?? 0;
          return NavigationDestination(
            icon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.badge_outlined)),
            selectedIcon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.badge_rounded)),
            label: l.driversTitle,
          );
        case 2:
          return NavigationDestination(icon: const Icon(Icons.event_note_outlined), selectedIcon: const Icon(Icons.event_note_rounded), label: l.bookingsTitle);
        case 3:
          final n = stats?.pendingTopups ?? 0;
          return NavigationDestination(
            icon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.account_balance_wallet_outlined)),
            selectedIcon: Badge(isLabelVisible: n > 0, label: Text('$n'), child: const Icon(Icons.account_balance_wallet_rounded)),
            label: l.walletsTitle,
          );
        default:
          return NavigationDestination(icon: const Icon(Icons.menu_rounded), selectedIcon: const Icon(Icons.menu_open_rounded), label: l.more);
      }
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) => shell.goBranch(branches[i], initialLocation: branches[i] == shell.currentIndex),
        destinations: [for (final b in branches) dest(b)],
      ),
    );
  }
}
