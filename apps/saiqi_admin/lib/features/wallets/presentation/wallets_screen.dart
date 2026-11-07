import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

final adminTopupsProvider = FutureProvider.autoDispose.family<List<TopupRequest>, TopupStatus?>((ref, status) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).listTopups(status: status);
});

final adminWalletDriversProvider = FutureProvider.autoDispose<List<AdminDriver>>((ref) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).listDrivers(status: DriverStatus.approved);
});

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.walletsTitle),
          bottom: TabBar(tabs: [Tab(text: l.topupsTitle), Tab(text: l.driversWallets)]),
        ),
        body: const TabBarView(children: [_TopupsTab(), _DriversTab()]),
      ),
    );
  }
}

class _TopupsTab extends ConsumerStatefulWidget {
  const _TopupsTab();

  @override
  ConsumerState<_TopupsTab> createState() => _TopupsTabState();
}

class _TopupsTabState extends ConsumerState<_TopupsTab> {
  TopupStatus? _status = TopupStatus.pending;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final topups = ref.watch(adminTopupsProvider(_status));
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final s in <TopupStatus?>[TopupStatus.pending, TopupStatus.approved, TopupStatus.rejected, null])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(s == null ? l.all : l.topupStatusLabel(s)),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminTopupsProvider(_status)),
            child: AsyncValueView<List<TopupRequest>>(
              value: topups,
              onRetry: () => ref.invalidate(adminTopupsProvider(_status)),
              isEmpty: (list) => list.isEmpty,
              emptyTitle: l.noTopupsAdmin,
              emptyIcon: Icons.add_card_outlined,
              data: (list) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _TopupTile(t: list[i], onChanged: () => ref.invalidate(adminTopupsProvider(_status))),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopupTile extends ConsumerWidget {
  const _TopupTile({required this.t, required this.onChanged});
  final TopupRequest t;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 10, 6),
        leading: const CircleAvatar(child: Icon(Icons.add_card_rounded)),
        title: Row(
          children: [
            Expanded(child: Text(t.driverName ?? t.driverPhone ?? '—', style: const TextStyle(fontWeight: FontWeight.w800))),
            MoneyText(t.amount, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.method}${t.reference != null ? ' · ${t.reference}' : ''}\n${Fmt.dateTime(t.createdAt, context.lang)}'),
            const SizedBox(height: 4),
            TopupStatusBadge(t.status),
          ],
        ),
        isThreeLine: true,
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _TopupSheet(t: t, onChanged: onChanged),
        ),
        trailing: Icon(t.proofPath != null ? Icons.image_outlined : Icons.image_not_supported_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _TopupSheet extends ConsumerStatefulWidget {
  const _TopupSheet({required this.t, required this.onChanged});
  final TopupRequest t;
  final VoidCallback onChanged;

  @override
  ConsumerState<_TopupSheet> createState() => _TopupSheetState();
}

class _TopupSheetState extends ConsumerState<_TopupSheet> {
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _review(bool approve) async {
    final l = context.l10n;
    if (!approve && _note.text.trim().isEmpty) {
      showAppSnack(context, l.err_reason_required, error: true);
      return;
    }
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).reviewTopup(widget.t.id, approve: approve, note: _note.text.trim().isEmpty ? null : _note.text.trim()),
      successMessage: approve ? l.topupApprovedMsg : l.topupRejectedMsg,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onChanged();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = widget.t;
    final perms = ref.watch(permsProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(t.driverName ?? '—', style: Theme.of(context).textTheme.titleLarge)),
              TopupStatusBadge(t.status),
            ]),
            const SizedBox(height: 8),
            MoneyText(t.amount, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            InfoRow(label: l.methodLabel, value: t.method),
            InfoRow(label: l.referenceLabel, value: t.reference),
            InfoRow(label: l.status, value: Fmt.dateTime(t.createdAt, context.lang)),
            if (t.reviewNote != null) InfoRow(label: l.reason, value: t.reviewNote),
            if (t.driverPhone != null) ContactActions(phone: t.driverPhone!),
            const SizedBox(height: 12),
            Text(l.proofImage, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            if (t.proofPath == null)
              Text(l.noProof, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
            else
              SecondaryButton(
                label: l.viewDocument,
                icon: Icons.zoom_in_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => ImageViewerPage(title: l.proofImage, bucket: Buckets.topupProofs, path: t.proofPath!),
                )),
              ),
            if (t.status == TopupStatus.pending && perms.canReviewTopups) ...[
              const SizedBox(height: 16),
              AppTextField(controller: _note, label: l.topupNoteHint, icon: Icons.notes_outlined, maxLines: 2),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: DangerButton(label: l.rejectTopup, onPressed: _busy ? null : () => _review(false))),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: PrimaryButton(label: l.approveTopup, icon: Icons.check_rounded, loading: _busy, onPressed: () => _review(true))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DriversTab extends ConsumerStatefulWidget {
  const _DriversTab();

  @override
  ConsumerState<_DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends ConsumerState<_DriversTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final drivers = ref.watch(adminWalletDriversProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: InputDecoration(hintText: l.searchPeople, prefixIcon: const Icon(Icons.search)),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: AsyncValueView<List<AdminDriver>>(
            value: drivers,
            onRetry: () => ref.invalidate(adminWalletDriversProvider),
            data: (all) {
              final list = (_query.isEmpty ? all : all.where((d) => d.displayName.toLowerCase().contains(_query) || d.phone.contains(_query)).toList())
                ..sort((a, b) => (a.balance ?? 0).compareTo(b.balance ?? 0));
              if (list.isEmpty) return EmptyView(title: l.noData);
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final d = list[i];
                  return Card(
                    child: ListTile(
                      leading: UserAvatar(url: d.avatarUrl, name: d.displayName),
                      title: Text(d.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Directionality(textDirection: TextDirection.ltr, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(PhoneUtils.pretty(d.phone)))),
                      trailing: MoneyText(d.balance ?? 0, style: TextStyle(fontWeight: FontWeight.w900, color: (d.balance ?? 0) == 0 ? AppColors.danger : null)),
                      onTap: () => context.push('/wallet/driver/${d.driver.id}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
