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
    final canCreate = ref.watch(permsProvider).canValidateDrivers;
    return Scaffold(
      appBar: AppBar(title: Text(l.driversTitle)),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _AddDriverSheet(
                  onCreated: () {
                    setState(() => _status = DriverStatus.draft);
                    ref.invalidate(adminDriversProvider(DriverStatus.draft));
                  },
                ),
              ),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l.addDriver),
            )
          : null,
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
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

class _AddDriverSheet extends ConsumerStatefulWidget {
  const _AddDriverSheet({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_AddDriverSheet> createState() => _AddDriverSheetState();
}

class _AddDriverSheetState extends ConsumerState<_AddDriverSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).createDriver(
            phone: _phone.text,
            password: _password.text,
            fullName: _name.text.trim(),
          ),
      successMessage: l.driverCreatedMsg,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onCreated();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.addDriver, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l.addDriverIntro, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              AppTextField(
                controller: _name,
                label: l.fullNameLabel,
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().length < 3) ? l.vFieldRequired : null,
              ),
              const SizedBox(height: 12),
              PhoneField(controller: _phone),
              const SizedBox(height: 12),
              PasswordField(controller: _password, validator: (v) => PasswordField.validateNew(context, v)),
              const SizedBox(height: 20),
              PrimaryButton(label: l.register, loading: _busy, onPressed: _create),
            ],
          ),
        ),
      ),
    );
  }
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
