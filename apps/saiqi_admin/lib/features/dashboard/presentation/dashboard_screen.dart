import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final stats = ref.watch(dashboardStatsProvider);
    final profile = ref.watch(profileProvider).value;
    final perms = ref.watch(permsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboard),
        actions: [NotificationBell(onPressed: () => context.push('/notifications'))],
      ),
      floatingActionButton: perms.canManageBookings
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/booking/new'),
              icon: const Icon(Icons.add_call),
              label: Text(l.createRequest),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardStatsProvider),
        child: AsyncValueView<AdminStats>(
          value: stats,
          onRetry: () => ref.invalidate(dashboardStatsProvider),
          data: (s) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(l.hello(profile?.displayName ?? ''), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              if (profile?.adminRole != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: StatusBadge(label: l.adminRoleLabel(profile!.adminRole!), color: AppColors.primary, icon: Icons.shield_outlined, dense: true),
                  ),
                ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  _Kpi(
                    icon: Icons.how_to_reg_outlined,
                    color: AppColors.warning,
                    label: l.kpiPendingDrivers,
                    value: '${s.pendingDrivers}',
                    highlight: s.pendingDrivers > 0,
                    onTap: perms.canValidateDrivers ? () => context.go('/drivers') : null,
                  ),
                  _Kpi(
                    icon: Icons.event_available_outlined,
                    color: AppColors.info,
                    label: l.kpiBookingsToday,
                    value: '${s.bookingsToday}',
                    onTap: perms.canManageBookings ? () => context.go('/bookings') : null,
                  ),
                  _Kpi(
                    icon: Icons.percent_rounded,
                    color: AppColors.success,
                    label: l.kpiCommissionsToday,
                    value: Fmt.mru(s.commissionsToday, context.lang),
                    onTap: perms.canConfigure ? () => context.push('/commissions') : null,
                  ),
                  _Kpi(
                    icon: Icons.report_gmailerrorred_outlined,
                    color: AppColors.danger,
                    label: l.kpiOpenComplaints,
                    value: '${s.openComplaints}',
                    highlight: s.openComplaints > 0,
                    onTap: perms.canHandleComplaints ? () => context.push('/complaints') : null,
                  ),
                  _Kpi(
                    icon: Icons.add_card_outlined,
                    color: AppColors.gold,
                    label: l.kpiPendingTopups,
                    value: '${s.pendingTopups}',
                    highlight: s.pendingTopups > 0,
                    onTap: perms.canReviewTopups ? () => context.go('/wallets') : null,
                  ),
                  _Kpi(icon: Icons.hourglass_bottom_rounded, color: AppColors.warning, label: l.kpiPendingBookings, value: '${s.pendingBookings}'),
                ],
              ),
              const SizedBox(height: 18),
              SectionCard(
                title: l.commissionsTitle,
                child: Column(
                  children: [
                    InfoRow(label: l.kpiCommissionsTotal, valueWidget: MoneyText(s.commissionsTotal, style: const TextStyle(fontWeight: FontWeight.w900))),
                    InfoRow(label: l.kpiApprovedDrivers, value: '${s.approvedDrivers}'),
                    InfoRow(label: l.kpiNewDrivers, value: '${s.newDrivers7d}'),
                    InfoRow(label: l.kpiClients, value: '${s.clients}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icon, required this.color, required this.label, required this.value, this.onTap, this.highlight = false});

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: highlight ? color.withValues(alpha: 0.10) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                  Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
