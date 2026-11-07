import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Liste des dossiers chauffeurs, filtrée par statut (en attente par défaut) et recherche.
class DriversScreen extends ConsumerStatefulWidget {
  const DriversScreen({super.key});

  @override
  ConsumerState<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends ConsumerState<DriversScreen> {
  DriverStatus? _status = DriverStatus.pending;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final drivers = ref.watch(adminDriversProvider(_status));
    return Scaffold(
      appBar: AppBar(title: Text(l.driversTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(hintText: l.searchPeople, prefixIcon: const Icon(Icons.search)),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip(l.all, null),
                for (final s in const [DriverStatus.pending, DriverStatus.approved, DriverStatus.rejected, DriverStatus.suspended, DriverStatus.draft])
                  _chip(l.driverStatusLabel(s), s),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(adminDriversProvider(_status)),
              child: AsyncValueView<List<AdminDriver>>(
                value: drivers,
                onRetry: () => ref.invalidate(adminDriversProvider(_status)),
                data: (all) {
                  final list = _query.isEmpty
                      ? all
                      : all.where((d) => d.displayName.toLowerCase().contains(_query) || d.phone.contains(_query)).toList();
                  if (list.isEmpty) return EmptyView(icon: Icons.people_outline, title: l.noData);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _DriverTile(d: list[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, DriverStatus? value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(label: Text(label), selected: _status == value, onSelected: (_) => setState(() => _status = value)),
      );
}

class _DriverTile extends StatelessWidget {
  const _DriverTile({required this.d});
  final AdminDriver d;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 10, 6),
        leading: UserAvatar(url: d.avatarUrl, name: d.displayName),
        title: Text(d.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality(textDirection: TextDirection.ltr, child: Text(PhoneUtils.pretty(d.phone))),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                DriverStatusBadge(d.driver.status, dense: true),
                if (d.accountStatus != AccountStatus.active) AccountStatusBadge(d.accountStatus),
                if (d.cityName(context.lang) != null)
                  StatusBadge(label: d.cityName(context.lang)!, color: AppColors.info, dense: true),
                if (d.balance != null) StatusBadge(label: Fmt.mru(d.balance!, context.lang), color: AppColors.success, dense: true),
              ],
            ),
            if (d.driver.status == DriverStatus.pending && d.driver.submittedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.pendingSince(Fmt.dateTime(d.driver.submittedAt!, context.lang)),
                    style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: const DirectionalChevron(),
        onTap: () => context.push('/driver/${d.driver.id}'),
      ),
    );
  }
}
