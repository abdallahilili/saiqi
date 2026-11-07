import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

final _ratesProvider = FutureProvider.autoDispose<List<CommissionRate>>((ref) => ref.watch(catalogRepositoryProvider).commissionRates());
final _historyProvider = FutureProvider.autoDispose<List<CommissionRecord>>((ref) => ref.watch(adminRepositoryProvider).commissionHistory());

/// Taux (défaut / service / ville / service+ville), réglages généraux et historique des commissions.
class CommissionsScreen extends ConsumerWidget {
  const CommissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.commissionsTitle),
          bottom: TabBar(tabs: [Tab(text: l.defaultRate), Tab(text: l.generalSettings), Tab(text: l.commissionHistory)]),
        ),
        body: const TabBarView(children: [_RatesTab(), _SettingsTab(), _HistoryTab()]),
      ),
    );
  }
}

class _RatesTab extends ConsumerWidget {
  const _RatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(appSettingsProvider);
    final rates = ref.watch(_ratesProvider);
    final cities = ref.watch(citiesProvider).value ?? const <City>[];
    final services = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    final lang = context.lang;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: l.defaultRate,
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final current = (settings.value ?? AppSettings.empty).defaultCommissionRate;
              final pct = await _askPercent(context, current * 100);
              if (pct == null || !context.mounted) return;
              final ok = await runAction(context, () => ref.read(adminRepositoryProvider).setSetting('default_commission_rate', pct / 100), successMessage: l.rateSaved);
              if (ok) ref.invalidate(appSettingsProvider);
            },
          ),
          child: Text(Fmt.percent((settings.value ?? AppSettings.empty).defaultCommissionRate),
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 8),
        Text(l.ratePriorityNote, style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Text(l.rateOverrides, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
              icon: const Icon(Icons.add),
              label: Text(l.addRate),
              onPressed: () => _editRate(context, ref, null),
            ),
          ],
        ),
        const SizedBox(height: 8),
        rates.when(
          loading: () => const Padding(padding: EdgeInsets.all(20), child: LoadingView()),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_ratesProvider)),
          data: (list) {
            if (list.isEmpty) return Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.noData)));
            return Column(
              children: [
                for (final r in list)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(Fmt.percent(r.rate), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                      title: Text(
                        [
                          if (r.serviceTypeId != null) services.where((s) => s.id == r.serviceTypeId).firstOrNull?.name(lang) ?? '—',
                          if (r.cityId != null) cities.where((c) => c.id == r.cityId).firstOrNull?.name(lang) ?? '—',
                        ].join(' + '),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(r.serviceTypeId != null && r.cityId != null
                          ? l.rateByServiceCity
                          : (r.serviceTypeId != null ? l.rateByService : l.rateByCity)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final ok = await confirmDialog(context, title: l.delete, message: l.deleteConfirm, destructive: true);
                          if (!ok || !context.mounted) return;
                          final done = await runAction(context, () => ref.read(adminRepositoryProvider).deleteCommissionRate(r.id));
                          if (done) ref.invalidate(_ratesProvider);
                        },
                      ),
                      onTap: () => _editRate(context, ref, r),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<double?> _askPercent(BuildContext context, double initial) async {
    final l = context.l10n;
    final ctrl = TextEditingController(text: initial == initial.roundToDouble() ? initial.round().toString() : initial.toString());
    final form = GlobalKey<FormState>();
    final res = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.rateField),
        content: Form(
          key: form,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(suffixText: '%'),
            validator: (v) {
              final n = double.tryParse((v ?? '').trim());
              return (n == null || n < 0 || n > 100) ? l.rateInvalid : null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () {
              if (form.currentState?.validate() ?? false) Navigator.pop(ctx, double.parse(ctrl.text.trim()));
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return res;
  }

  Future<void> _editRate(BuildContext context, WidgetRef ref, CommissionRate? existing) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _RateEditor(existing: existing, onSaved: () => ref.invalidate(_ratesProvider)),
    );
  }
}

class _RateEditor extends ConsumerStatefulWidget {
  const _RateEditor({required this.existing, required this.onSaved});
  final CommissionRate? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_RateEditor> createState() => _RateEditorState();
}

class _RateEditorState extends ConsumerState<_RateEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _rate = TextEditingController(
    text: widget.existing == null ? '' : (widget.existing!.rate * 100).toString().replaceAll(RegExp(r'\.0$'), ''),
  );
  late String? _serviceId = widget.existing?.serviceTypeId;
  late String? _cityId = widget.existing?.cityId;
  bool _busy = false;

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_serviceId == null && _cityId == null) {
      showAppSnack(context, l.rateNeedsScope, error: true);
      return;
    }
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).upsertCommissionRate(
            id: widget.existing?.id,
            rate: double.parse(_rate.text.trim()) / 100,
            serviceTypeId: _serviceId,
            cityId: _cityId,
          ),
      successMessage: l.rateSaved,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onSaved();
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
              Text(l.addRate, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              ServiceTypeDropdown(value: _serviceId, allowAll: true, onChanged: (v) => setState(() => _serviceId = v)),
              const SizedBox(height: 12),
              CityDropdown(value: _cityId, allowAll: true, onChanged: (v) => setState(() => _cityId = v)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: l.rateField, suffixText: '%'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  return (n == null || n < 0 || n > 100) ? l.rateInvalid : null;
                },
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

/// Réglages généraux (délai, seuils, support) et comptes de réception des recharges.
class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab();

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  final _timeout = TextEditingController();
  final _low = TextEditingController();
  final _minTopup = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final Map<String, TextEditingController> _accounts = {};
  List<TopupMethod> _methods = [];
  bool _loaded = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_timeout, _low, _minTopup, _phone, _whatsapp, ..._accounts.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(AppSettings s) {
    if (_loaded) return;
    _loaded = true;
    _timeout.text = '${s.responseTimeoutMinutes}';
    _low.text = '${s.lowBalanceThreshold}';
    _minTopup.text = '${s.minTopupAmount}';
    _phone.text = s.supportPhone;
    _whatsapp.text = s.supportWhatsapp;
    _methods = s.topupMethods;
    for (final m in _methods) {
      _accounts[m.id] = TextEditingController(text: m.account);
    }
  }

  Future<void> _save() async {
    final l = context.l10n;
    final repo = ref.read(adminRepositoryProvider);
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      await repo.setSetting('response_timeout_minutes', int.tryParse(_timeout.text.trim()) ?? 10);
      await repo.setSetting('low_balance_threshold', int.tryParse(_low.text.trim()) ?? 100);
      await repo.setSetting('min_topup_amount', int.tryParse(_minTopup.text.trim()) ?? 100);
      await repo.setSetting('support_phone', _phone.text.trim());
      await repo.setSetting('support_whatsapp', _whatsapp.text.trim());
      await repo.setSetting('topup_methods', [
        for (final m in _methods) TopupMethod(id: m.id, nameAr: m.nameAr, nameFr: m.nameFr, account: _accounts[m.id]?.text.trim() ?? '').toJson(),
      ]);
      ref.invalidate(appSettingsProvider);
    }, successMessage: l.settingsSaved);
    if (mounted) setState(() => _busy = false);
    if (!ok) return;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = ref.watch(appSettingsProvider);
    return AsyncValueView<AppSettings>(
      value: settings,
      onRetry: () => ref.invalidate(appSettingsProvider),
      data: (s) {
        _fill(s);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            IntField(controller: _timeout, label: l.responseTimeout, icon: Icons.timer_outlined, min: 1, max: 1440),
            const SizedBox(height: 12),
            IntField(controller: _low, label: l.lowBalanceThresholdField, icon: Icons.warning_amber_rounded, min: 0),
            const SizedBox(height: 12),
            IntField(controller: _minTopup, label: l.minTopupField, icon: Icons.add_card_outlined, min: 1),
            const SizedBox(height: 12),
            AppTextField(controller: _phone, label: l.supportPhoneField, icon: Icons.call_outlined, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr),
            const SizedBox(height: 12),
            AppTextField(controller: _whatsapp, label: l.supportWhatsappField, icon: Icons.chat_outlined, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr),
            const SizedBox(height: 20),
            Text(l.topupAccountsTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final m in _methods) ...[
              AppTextField(controller: _accounts[m.id]!, label: '${m.name(context.lang)} — ${l.accountHint}', icon: Icons.account_balance_outlined, textDirection: TextDirection.ltr),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            PrimaryButton(label: l.save, loading: _busy, onPressed: _save),
          ],
        );
      },
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final history = ref.watch(_historyProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_historyProvider),
      child: AsyncValueView<List<CommissionRecord>>(
        value: history,
        onRetry: () => ref.invalidate(_historyProvider),
        isEmpty: (list) => list.isEmpty,
        emptyTitle: l.noCommissions,
        emptyIcon: Icons.percent_rounded,
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = list[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (c.isRefunded ? AppColors.neutral : AppColors.success).withValues(alpha: 0.14),
                  child: Icon(c.isRefunded ? Icons.undo_rounded : Icons.percent_rounded, color: c.isRefunded ? AppColors.neutral : AppColors.success),
                ),
                title: Text(c.driverName ?? '—', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${c.serviceName(context.lang) ?? ''} · ${Fmt.percent(c.rate)}\n${Fmt.dateTime(c.createdAt, context.lang)}'),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(c.amount, style: TextStyle(fontWeight: FontWeight.w900, decoration: c.isRefunded ? TextDecoration.lineThrough : null)),
                    if (c.isRefunded) StatusBadge(label: l.refundedLabel, color: AppColors.neutral, dense: true),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
