import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Navigation principale : Accueil · Courses · Portefeuille · Profil.
class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final pending = ref.watch(incomingRequestsProvider).value?.length ?? 0;
    final lowBalance = _isLow(ref);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: Badge(isLabelVisible: pending > 0, label: Text('$pending'), child: const Icon(Icons.home_outlined)),
            selectedIcon: Badge(isLabelVisible: pending > 0, label: Text('$pending'), child: const Icon(Icons.home_rounded)),
            label: l.home,
          ),
          NavigationDestination(icon: const Icon(Icons.route_outlined), selectedIcon: const Icon(Icons.route_rounded), label: l.myTrips),
          NavigationDestination(
            icon: Badge(isLabelVisible: lowBalance, smallSize: 9, child: const Icon(Icons.account_balance_wallet_outlined)),
            selectedIcon: Badge(isLabelVisible: lowBalance, smallSize: 9, child: const Icon(Icons.account_balance_wallet_rounded)),
            label: l.wallet,
          ),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person_rounded), label: l.profile),
        ],
      ),
    );
  }

  bool _isLow(WidgetRef ref) {
    final balance = ref.watch(walletProvider).value?.balance;
    final threshold = (ref.watch(appSettingsProvider).value ?? AppSettings.empty).lowBalanceThreshold;
    return balance != null && balance < threshold;
  }
}
