import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import '../features/application/presentation/application_hub_screen.dart';
import '../features/application/presentation/availability_screen.dart';
import '../features/application/presentation/documents_screen.dart';
import '../features/application/presentation/personal_info_screen.dart';
import '../features/application/presentation/services_screen.dart';
import '../features/application/presentation/vehicle_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/shell_scaffold.dart';
import '../features/pending/presentation/pending_screen.dart';
import '../features/profile/presentation/help_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/reviews_screen.dart';
import '../features/requests/presentation/request_detail_screen.dart';
import '../features/trips/presentation/trip_detail_screen.dart';
import '../features/trips/presentation/trips_screen.dart';
import '../features/wallet/presentation/topup_screen.dart';
import '../features/wallet/presentation/wallet_screen.dart';
import 'providers.dart';

/// Rafraîchit le routeur quand la session, le profil ou le dossier changent.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(profileProvider, (_, _) => notifyListeners());
    ref.listen(myDriverProvider, (_, _) => notifyListeners());
    ref.listen(languageChosenProvider, (_, _) => notifyListeners());
  }
}

const _publicRoutes = {'/splash', '/welcome', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    if (!ref.read(languageChosenProvider)) return loc == '/welcome' ? null : '/welcome';

    final profile = ref.read(profileProvider);
    if (!profile.hasValue) return profile.hasError ? '/login' : (loc == '/splash' ? null : '/splash');
    if (profile.requireValue == null) return (loc == '/login' || loc == '/register') ? null : '/login';

    final driver = ref.read(myDriverProvider);
    if (!driver.hasValue) return loc == '/splash' ? null : '/splash';
    final d = driver.requireValue;
    if (d == null) return loc == '/splash' ? null : '/splash';

    switch (d.status) {
      case DriverStatus.draft:
      case DriverStatus.rejected:
        final ok = loc.startsWith('/application') || loc.startsWith('/edit') || loc == '/account';
        return ok ? null : '/application';
      case DriverStatus.pending:
        return (loc == '/pending' || loc == '/account') ? null : '/pending';
      case DriverStatus.suspended:
        return (loc == '/suspended' || loc == '/account') ? null : '/suspended';
      case DriverStatus.approved:
        if (_publicRoutes.contains(loc) || loc.startsWith('/application') || loc == '/pending' || loc == '/suspended') {
          return '/home';
        }
        return null;
    }
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
        builder: (context, _) => LanguageWelcomeScreen(
          subtitle: context.l10n.driverBadge,
          onContinue: () {},
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, _) => LoginScreen(roleBadge: context.l10n.driverBadge, onRegister: () => context.go('/register')),
      ),
      GoRoute(
        path: '/register',
        builder: (context, _) => RegisterScreen(roleBadge: context.l10n.driverBadge, onLogin: () => context.go('/login')),
      ),

      // ---- Dossier chauffeur ----
      GoRoute(path: '/application', builder: (_, _) => const ApplicationHubScreen()),
      GoRoute(path: '/edit/info', builder: (_, _) => const PersonalInfoScreen()),
      GoRoute(path: '/edit/documents', builder: (_, _) => const DocumentsScreen()),
      GoRoute(path: '/edit/vehicle', builder: (_, _) => const VehicleScreen()),
      GoRoute(path: '/edit/services', builder: (_, _) => const ServicesScreen()),
      GoRoute(path: '/edit/availability', builder: (_, _) => const AvailabilityScreen()),
      GoRoute(path: '/pending', builder: (_, _) => const PendingScreen()),
      GoRoute(path: '/suspended', builder: (_, _) => const SuspendedScreen()),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),

      // ---- Application principale ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/trips', builder: (_, _) => const TripsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
        ],
      ),
      GoRoute(path: '/request/:id', parentNavigatorKey: rootKey, builder: (_, s) => RequestDetailScreen(bookingId: s.pathParameters['id']!)),
      GoRoute(path: '/trip/:id', parentNavigatorKey: rootKey, builder: (_, s) => TripDetailScreen(bookingId: s.pathParameters['id']!)),
      GoRoute(path: '/topup', parentNavigatorKey: rootKey, builder: (_, _) => const TopupScreen()),
      GoRoute(path: '/reviews', parentNavigatorKey: rootKey, builder: (_, _) => const ReviewsScreen()),
      GoRoute(path: '/help', parentNavigatorKey: rootKey, builder: (_, _) => const HelpScreen()),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (context, _) => NotificationsScreen(onOpen: (ctx, data) => openFromNotification(ctx, data)),
      ),
    ],
  );
});

/// Ouvre l'écran concerné à partir de `data` d'une notification (`screen`, `booking_id`).
void openFromNotification(BuildContext context, Map<String, dynamic> data) {
  final router = GoRouter.of(context);
  final bookingId = data['booking_id'] as String?;
  switch (data['screen']) {
    case 'request':
      if (bookingId != null) router.push('/request/$bookingId');
    case 'booking':
      if (bookingId != null) router.push('/trip/$bookingId');
    case 'wallet':
      router.go('/wallet');
    case 'reviews':
      router.push('/reviews');
    case 'application':
      router.go('/application');
    case 'home':
      router.go('/home');
  }
}
