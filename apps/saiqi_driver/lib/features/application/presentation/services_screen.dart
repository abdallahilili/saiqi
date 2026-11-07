import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Services proposés : type, villes desservies, prix et unité.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final services = ref.watch(driverServicesProvider);
    final types = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    final cities = ref.watch(citiesProvider).value ?? const <City>[];

    return Scaffold(
      appBar: AppBar(title: Text(l.stepServices)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, null, services.value ?? const []),
        icon: const Icon(Icons.add),
        label: Text(l.addService),
      ),
      body: AsyncValueView<List<DriverService>>(
        value: services,
        onRetry: () => ref.invalidate(driverServicesProvider),
        isEmpty: (list) => list.isEmpty,
        emptyTitle: l.noServicesYet,
        emptyMessage: l.noServicesHint,
        emptyIcon: Icons.payments_outlined,
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final s = list[i];
            final type = types.where((t) => t.id == s.serviceTypeId).firstOrNull;
            final cityNames = cities.where((c) => s.cityIds.contains(c.id)).map((c) => c.name(context.lang)).join('، ');
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(serviceIconFor(type?.icon ?? ''), color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(type?.name(context.lang) ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${Fmt.mru(s.price, context.lang)} ${l.priceUnitLabel(s.priceUnit)}\n$cityNames'),
                isThreeLine: true,
                trailing: Switch(
                  value: s.isActive,
                  onChanged: (v) => runAction(context, () async {
                    await ref.read(driverRepositoryProvider).saveService(DriverService(
                          driverId: s.driverId,
                          serviceTypeId: s.serviceTypeId,
                          cityIds: s.cityIds,
                          price: s.price,
                          priceUnit: s.priceUnit,
                          isActive: v,
                        ));
                    ref.invalidate(driverServicesProvider);
                  }),
                ),
                onTap: () => _openEditor(context, ref, s, list),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, DriverService? existing, List<DriverService> all) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ServiceEditor(existing: existing, taken: all.map((s) => s.serviceTypeId).toSet()),
    );
  }
}

class _ServiceEditor extends ConsumerStatefulWidget {
  const _ServiceEditor({required this.existing, required this.taken});
  final DriverService? existing;
  final Set<String> taken;

  @override
  ConsumerState<_ServiceEditor> createState() => _ServiceEditorState();
}

class _ServiceEditorState extends ConsumerState<_ServiceEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _price = TextEditingController(text: widget.existing?.price.toString() ?? '');
  late String? _typeId = widget.existing?.serviceTypeId;
  late PriceUnit _unit = widget.existing?.priceUnit ?? PriceUnit.perTrip;
  late final Set<String> _cityIds = {...?widget.existing?.cityIds};
  bool _busy = false;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_cityIds.isEmpty) {
      showAppSnack(context, l.selectAtLeastOneCity, error: true);
      return;
    }
    final driverId = ref.read(driverIdProvider);
    if (driverId == null) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      await ref.read(driverRepositoryProvider).saveService(DriverService(
            driverId: driverId,
            serviceTypeId: _typeId!,
            cityIds: _cityIds.toList(),
            price: int.parse(_price.text.trim()),
            priceUnit: _unit,
            isActive: widget.existing?.isActive ?? true,
          ));
      ref.invalidate(driverServicesProvider);
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmDialog(context, title: l.delete, message: l.deleteServiceConfirm, destructive: true);
    if (!ok || !mounted) return;
    final done = await runAction(context, () async {
      await ref.read(driverRepositoryProvider).deleteService(widget.existing!.id!);
      ref.invalidate(driverServicesProvider);
    });
    if (done && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cities = ref.watch(citiesProvider).value ?? const <City>[];
    final allTypes = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    final available = allTypes.where((t) => t.id == widget.existing?.serviceTypeId || !widget.taken.contains(t.id)).map((t) => t.id).toSet();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.existing == null ? l.addService : l.editService, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ServiceTypeDropdown(
                value: _typeId,
                onlyIds: available,
                enabled: widget.existing == null,
                onChanged: (v) => setState(() => _typeId = v),
                validator: (v) => v == null ? l.vFieldRequired : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(flex: 3, child: IntField(controller: _price, label: l.servicePriceField, icon: Icons.payments_outlined, min: 1)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<PriceUnit>(
                      initialValue: _unit,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.priceUnitField),
                      items: [for (final u in PriceUnit.values) DropdownMenuItem(value: u, child: Text(l.priceUnitLabel(u)))],
                      onChanged: (u) => setState(() => _unit = u ?? PriceUnit.perTrip),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l.serviceCities, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in cities)
                    FilterChip(
                      label: Text(c.name(context.lang)),
                      selected: _cityIds.contains(c.id),
                      onSelected: (v) => setState(() => v ? _cityIds.add(c.id) : _cityIds.remove(c.id)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
              if (widget.existing != null) ...[
                const SizedBox(height: 10),
                DangerButton(label: l.delete, icon: Icons.delete_outline, onPressed: _delete),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
