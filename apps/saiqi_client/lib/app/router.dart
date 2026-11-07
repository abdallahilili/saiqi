import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/core.dart';
import '../features/booking/presentation/booking_detail_screen.dart';
import '../features/booking/presentation/booking_form_screen.dart';
import '../features/booking/presentation/bookings_screen.dart';
import '../features/drivers/presentation/driver_detail_screen.dart';
import '../features/drivers/presentation/drivers_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/help_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(profileProvider, (_, _) => notifyListeners());
    ref.listen(languageChosenProvider, (_, _) => notifyListeners());
  }
}

const _authRoutes = {'/splash', '/welcome', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    if (!ref.read(languageChosenProvider)) return loc == '/welcome' ? null : '/welcome';

    final profile = ref.read(profileProvider);
    if (!profile.hasValue) return profile.hasError ? '/login' : (loc == '/splash' ? null : '/splash');
    if (profile.requireValue == null) return (loc == '/login' || loc == '/register') ? null : '/login';

    return _authRoutes.contains(loc) ? '/home' : null;
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
        builder: (context, _) => LanguageWelcomeScreen(subtitle: context.l10n.clientBadge, onContinue: () {}),
      ),
      GoRoute(
        path: '/login',
        builder: (context, _) => LoginScreen(roleBadge: context.l10n.clientBadge, onRegister: () => context.go('/register')),
      ),
      GoRoute(
        path: '/register',
        builder: (context, _) => RegisterScreen(roleBadge: context.l10n.clientBadge, onLogin: () => context.go('/login')),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ClientShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
        ],
      ),

      GoRoute(
        path: '/drivers',
        parentNavigatorKey: rootKey,
        builder: (_, s) => DriversScreen(
          serviceTypeId: s.uri.queryParameters['service'],
          cityId: s.uri.queryParameters['city'],
        ),
      ),
      GoRoute(
        path: '/driver/:id',
        parentNavigatorKey: rootKey,
        builder: (_, s) => DriverDetailScreen(
          driverId: s.pathParameters['id']!,
          serviceTypeId: s.uri.queryParameters['service'],
          cityId: s.uri.queryParameters['city'],
        ),
      ),
      GoRoute(
        path: '/book/:driverId',
        parentNavigatorKey: rootKey,
        builder: (_, s) => BookingFormScreen(
          driverId: s.pathParameters['driverId']!,
          serviceTypeId: s.uri.queryParameters['service'],
          cityId: s.uri.queryParameters['city'],
        ),
      ),
      GoRoute(path: '/booking/:id', parentNavigatorKey: rootKey, builder: (_, s) => BookingDetailScreen(bookingId: s.pathParameters['id']!)),
      GoRoute(path: '/help', parentNavigatorKey: rootKey, builder: (_, _) => const HelpScreen()),
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
  switch (data['screen']) {
    case 'booking':
      if (bookingId != null) router.push('/booking/$bookingId');
    case 'home':
      router.go('/home');
  }
}

class _ClientShell extends ConsumerWidget {
  const _ClientShell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.search_rounded), selectedIcon: const Icon(Icons.search_rounded), label: l.home),
          NavigationDestination(icon: const Icon(Icons.event_note_outlined), selectedIcon: const Icon(Icons.event_note_rounded), label: l.myBookings),
          NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: l.favoritesTitle),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person_rounded), label: l.profile),
        ],
      ),
    );
  }
}
