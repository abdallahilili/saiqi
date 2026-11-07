import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    final driver = ref.watch(myDriverProvider).value;
    final stats = ref.watch(statsProvider);
    final vehicle = ref.watch(vehicleProvider).value;
    final services = ref.watch(driverServicesProvider).value ?? const <DriverService>[];

    final preview = driver == null
        ? null
        : PublicDriver(
            driverId: driver.id,
            fullName: profile?.displayName,
            avatarUrl: profile?.avatarUrl,
            cityId: driver.cityId,
            ratingAvg: driver.ratingAvg,
            ratingCount: driver.ratingCount,
            completedCount: driver.completedCount,
            isAvailable: driver.isAvailable,
            vehicleBrand: vehicle?.brand,
            vehicleModel: vehicle?.model,
            vehicleYear: vehicle?.year,
            seats: vehicle?.seats,
            vehiclePhotos: vehicle?.photoPaths ?? const [],
            price: services.where((s) => s.isActive).map((s) => s.price).fold<int?>(null, (a, b) => a == null || b < a ? b : a),
            priceUnit: services.where((s) => s.isActive).firstOrNull?.priceUnit,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myProfile),
        actions: [NotificationBell(onPressed: () => context.push('/notifications'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              UserAvatar(url: profile?.avatarUrl, name: profile?.displayName ?? '', radius: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile?.displayName ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    Directionality(textDirection: TextDirection.ltr, child: Text(PhoneUtils.pretty(profile?.phone))),
                    const SizedBox(height: 6),
                    if (driver != null) DriverStatusBadge(driver.status, dense: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          stats.when(
            loading: () => const SizedBox(height: 90, child: LoadingView()),
            error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(statsProvider)),
            data: (s) => Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _StatTile(icon: Icons.check_circle_outline, label: l.completedTrips, value: '${s.completedCount}')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.star_rate_rounded,
                        label: l.ratingLabel,
                        value: s.ratingCount == 0 ? '—' : '${Fmt.rating(s.ratingAvg)} (${s.ratingCount})',
                        onTap: () => context.push('/reviews'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _StatTile(icon: Icons.payments_outlined, label: l.revenueGross, value: Fmt.mru(s.revenueGross, context.lang))),
                    const SizedBox(width: 10),
                    Expanded(child: _StatTile(icon: Icons.percent_rounded, label: l.commissionsPaid, value: Fmt.mru(s.commissionsPaid, context.lang))),
                  ],
                ),
                const SizedBox(height: 10),
                _StatTile(icon: Icons.savings_outlined, label: l.revenueNet, value: Fmt.mru(s.revenueNet, context.lang), wide: true),
              ],
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: 20),
            Text(l.publicProfile, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(l.publicProfileHint, style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            DriverCard(driver: preview),
          ],
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                _MenuTile(icon: Icons.person_outline, title: l.editPersonalInfo, onTap: () => context.push('/edit/info')),
                const Divider(),
                _MenuTile(icon: Icons.directions_car_outlined, title: l.stepVehicle, onTap: () => context.push('/edit/vehicle')),
                const Divider(),
                _MenuTile(icon: Icons.payments_outlined, title: l.stepServices, onTap: () => context.push('/edit/services')),
                const Divider(),
                _MenuTile(icon: Icons.schedule_outlined, title: l.stepAvailability, onTap: () => context.push('/edit/availability')),
                const Divider(),
                _MenuTile(icon: Icons.badge_outlined, title: l.myDocuments, onTap: () => context.push('/edit/documents')),
                const Divider(),
                _MenuTile(icon: Icons.reviews_outlined, title: l.reviewsReceived, onTap: () => context.push('/reviews')),
                const Divider(),
                _MenuTile(icon: Icons.support_agent_outlined, title: l.helpAndReport, onTap: () => context.push('/help')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AccountSettingsSection(),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, this.onTap, this.wide = false});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(leading: Icon(icon), title: Text(title), trailing: const DirectionalChevron(), onTap: onTap);
}
