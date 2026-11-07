import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';
import '../../requests/presentation/request_actions.dart';
import '../../trips/presentation/trips_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    final requests = ref.watch(incomingRequestsProvider);
    final bookings = ref.watch(driverBookingsProvider);

    Future<void> refresh() async {
      ref.invalidate(incomingRequestsProvider);
      ref.invalidate(driverBookingsProvider);
      ref.invalidate(walletProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [NotificationBell(onPressed: () => context.push('/notifications'))],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.hello(profile?.displayName ?? ''), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            const _AvailabilityCard(),
            const SizedBox(height: 12),
            const _WalletSummary(),
            const SizedBox(height: 20),
            Text(l.incomingRequests, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            requests.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
              error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(incomingRequestsProvider)),
              data: (list) {
                final live = list.where((r) => r.expiresAt == null || r.expiresAt!.isAfter(DateTime.now())).toList();
                if (live.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: EmptyView(
                        icon: Icons.notifications_none_rounded,
                        title: l.noIncomingRequests,
                        message: l.noIncomingHint,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final r in live) ...[IncomingRequestCard(request: r), const SizedBox(height: 12)],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(l.upcomingTrips, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                TextButton(onPressed: () => context.go('/trips'), child: Text(l.seeAll)),
              ],
            ),
            const SizedBox(height: 6),
            bookings.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: LoadingView()),
              error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(driverBookingsProvider)),
              data: (list) {
                final upcoming = list.where((b) => b.status.isActive).toList()
                  ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
                if (upcoming.isEmpty) {
                  return Card(child: Padding(padding: const EdgeInsets.all(8), child: EmptyView(icon: Icons.route_outlined, title: l.noTrips)));
                }
                return Column(
                  children: [
                    for (final b in upcoming.take(3)) ...[TripCard(booking: b), const SizedBox(height: 10)],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityCard extends ConsumerStatefulWidget {
  const _AvailabilityCard();

  @override
  ConsumerState<_AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends ConsumerState<_AvailabilityCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final driver = ref.watch(myDriverProvider).value;
    final on = driver?.isAvailable ?? false;
    final color = on ? AppColors.success : AppColors.neutral;
    return Card(
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Icon(on ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded, color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(on ? l.availabilityOn : l.availabilityOff, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(l.availabilityToggleHint, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Switch(
              value: on,
              onChanged: _busy
                  ? null
                  : (v) async {
                      setState(() => _busy = true);
                      await runAction(context, () => ref.read(driverRepositoryProvider).setAvailable(v));
                      if (mounted) setState(() => _busy = false);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletSummary extends ConsumerWidget {
  const _WalletSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final wallet = ref.watch(walletProvider);
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.empty;
    final balance = wallet.value?.balance ?? 0;
    final low = wallet.hasValue && balance < settings.lowBalanceThreshold;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: scheme.onPrimary.withValues(alpha: 0.85)),
                const SizedBox(width: 8),
                Text(l.walletBalance, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85))),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: scheme.onPrimary),
                  onPressed: () => context.push('/topup'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(l.topUp),
                ),
              ],
            ),
            MoneyText(balance, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: scheme.onPrimary)),
            if (low) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.lowBalanceWarning, style: TextStyle(color: scheme.onPrimary, fontSize: 12.5))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
