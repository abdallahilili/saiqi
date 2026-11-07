import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

final _allCitiesProvider = FutureProvider.autoDispose<List<City>>((ref) => ref.watch(catalogRepositoryProvider).cities(includeInactive: true));
final _allServicesProvider =
    FutureProvider.autoDispose<List<ServiceType>>((ref) => ref.watch(catalogRepositoryProvider).serviceTypes(includeInactive: true));

/// CRUD des villes et des types de services (super_admin).
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l.catalogTitle), bottom: TabBar(tabs: [Tab(text: l.citiesTitle), Tab(text: l.servicesTitle)])),
          floatingActionButton: AnimatedBuilder(
            animation: DefaultTabController.of(context),
            builder: (fabContext, _) {
              final isCities = DefaultTabController.of(fabContext).index == 0;
              return FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: Text(isCities ? l.addCity : l.addServiceType),
                onPressed: () => isCities ? _editCity(context, ref, null) : _editService(context, ref, null),
              );
            },
          ),
          body: TabBarView(
            children: [
              _CitiesTab(onEdit: (c) => _editCity(context, ref, c)),
              _ServicesTab(onEdit: (s) => _editService(context, ref, s)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editCity(BuildContext context, WidgetRef ref, City? city) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _NameSheet(
          title: city == null ? context.l10n.addCity : context.l10n.editCity,
          initialAr: city?.nameAr,
          initialFr: city?.nameFr,
          initialActive: city?.isActive ?? true,
          onDelete: city == null
              ? null
              : () async {
                  await ref.read(adminRepositoryProvider).deleteCity(city.id);
                  ref.invalidate(_allCitiesProvider);
                  ref.invalidate(citiesProvider);
                },
          onSave: (ar, fr, _, active) async {
            await ref.read(adminRepositoryProvider).saveCity(City(id: city?.id ?? '', nameAr: ar, nameFr: fr, isActive: active), isNew: city == null);
            ref.invalidate(_allCitiesProvider);
            ref.invalidate(citiesProvider);
          },
        ),
      );

  Future<void> _editService(BuildContext context, WidgetRef ref, ServiceType? s) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => _NameSheet(
          title: s == null ? context.l10n.addServiceType : context.l10n.editServiceType,
          initialAr: s?.nameAr,
          initialFr: s?.nameFr,
          initialActive: s?.isActive ?? true,
          initialIcon: s?.icon ?? 'directions_car',
          withIcon: true,
          onDelete: s == null
              ? null
              : () async {
                  await ref.read(adminRepositoryProvider).deleteServiceType(s.id);
                  ref.invalidate(_allServicesProvider);
                  ref.invalidate(serviceTypesProvider);
                },
          onSave: (ar, fr, icon, active) async {
            await ref
                .read(adminRepositoryProvider)
                .saveServiceType(ServiceType(id: s?.id ?? '', nameAr: ar, nameFr: fr, icon: icon ?? 'directions_car', isActive: active), isNew: s == null);
            ref.invalidate(_allServicesProvider);
            ref.invalidate(serviceTypesProvider);
          },
        ),
      );
}

class _CitiesTab extends ConsumerWidget {
  const _CitiesTab({required this.onEdit});
  final void Function(City) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(_allCitiesProvider);
    return AsyncValueView<List<City>>(
      value: cities,
      onRetry: () => ref.invalidate(_allCitiesProvider),
      data: (list) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.location_city_outlined)),
            title: Text(list[i].name(context.lang), style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(context.lang == 'fr' ? list[i].nameAr : list[i].nameFr),
            trailing: StatusBadge(label: list[i].isActive ? context.l10n.activeField : context.l10n.accountStatusLabel(AccountStatus.suspended), color: list[i].isActive ? AppColors.success : AppColors.neutral, dense: true),
            onTap: () => onEdit(list[i]),
          ),
        ),
      ),
    );
  }
}

class _ServicesTab extends ConsumerWidget {
  const _ServicesTab({required this.onEdit});
  final void Function(ServiceType) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(_allServicesProvider);
    return AsyncValueView<List<ServiceType>>(
      value: services,
      onRetry: () => ref.invalidate(_allServicesProvider),
      data: (list) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(serviceIconFor(list[i].icon))),
            title: Text(list[i].name(context.lang), style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(context.lang == 'fr' ? list[i].nameAr : list[i].nameFr),
            trailing: StatusBadge(label: list[i].isActive ? context.l10n.activeField : context.l10n.accountStatusLabel(AccountStatus.suspended), color: list[i].isActive ? AppColors.success : AppColors.neutral, dense: true),
            onTap: () => onEdit(list[i]),
          ),
        ),
      ),
    );
  }
}

class _NameSheet extends StatefulWidget {
  const _NameSheet({
    required this.title,
    required this.onSave,
    this.onDelete,
    this.initialAr,
    this.initialFr,
    this.initialActive = true,
    this.initialIcon = 'directions_car',
    this.withIcon = false,
  });

  final String title;
  final String? initialAr;
  final String? initialFr;
  final bool initialActive;
  final String initialIcon;
  final bool withIcon;
  final Future<void> Function(String ar, String fr, String? icon, bool active) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _ar = TextEditingController(text: widget.initialAr);
  late final TextEditingController _fr = TextEditingController(text: widget.initialFr);
  late bool _active = widget.initialActive;
  late String _icon = widget.initialIcon;
  bool _busy = false;

  @override
  void dispose() {
    _ar.dispose();
    _fr.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () => widget.onSave(_ar.text.trim(), _fr.text.trim(), widget.withIcon ? _icon : null, _active), successMessage: context.l10n.saved);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmDialog(context, title: l.delete, message: l.deleteConfirm, destructive: true);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.onDelete!();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showAppSnack(context, l.deleteBlocked, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
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
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              AppTextField(controller: _ar, label: l.nameArField, validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null),
              const SizedBox(height: 12),
              AppTextField(controller: _fr, label: l.nameFrField, textDirection: TextDirection.ltr, validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null),
              if (widget.withIcon) ...[
                const SizedBox(height: 14),
                Text(l.iconField, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in serviceIconChoices)
                      ChoiceChip(
                        label: Icon(serviceIconFor(name), size: 22),
                        selected: _icon == name,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _icon = name),
                      ),
                  ],
                ),
              ],
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(l.activeField), value: _active, onChanged: (v) => setState(() => _active = v)),
              const SizedBox(height: 8),
              PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 10),
                DangerButton(label: l.delete, icon: Icons.delete_outline, onPressed: _busy ? null : _delete),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
