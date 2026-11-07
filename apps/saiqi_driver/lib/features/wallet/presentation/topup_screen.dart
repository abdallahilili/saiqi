import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';

/// Demande de recharge : montant, moyen de paiement, référence, preuve en photo.
class TopupScreen extends ConsumerStatefulWidget {
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  TopupMethod? _method;
  String? _proofPath;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _submit(AppSettings settings) async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final ok = await runAction(context, () async {
      await ref.read(walletRepositoryProvider).requestTopup(
            amount: int.parse(_amount.text.trim()),
            method: _method!.name(context.lang),
            reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            proofPath: _proofPath,
          );
    }, successMessage: l.topupSubmitted);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settingsAsync = ref.watch(appSettingsProvider);
    final settings = settingsAsync.value ?? AppSettings.empty;
    final methods = settings.topupMethods;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.requestTopup)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.topupHowTo, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          if (methods.every((m) => m.account.isEmpty))
            InfoBanner(icon: Icons.info_outline, color: AppColors.warning, message: l.noAccountConfigured)
          else
            for (final m in methods.where((m) => m.account.isNotEmpty))
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.account_balance_outlined)),
                  title: Text(m.name(context.lang), style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Directionality(textDirection: TextDirection.ltr, child: Align(alignment: AlignmentDirectional.centerStart, child: Text(m.account, style: const TextStyle(fontSize: 16)))),
                  trailing: IconButton(
                    tooltip: l.copy,
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: m.account));
                      showAppSnack(context, l.copied);
                    },
                  ),
                ),
              ),
          const SizedBox(height: 18),
          Form(
            key: _form,
            child: Column(
              children: [
                IntField(controller: _amount, label: l.topupAmount, icon: Icons.payments_outlined, min: settings.minTopupAmount),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 12),
                    child: Text(l.minTopup(Fmt.mru(settings.minTopupAmount, context.lang)), style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ),
                ),
                DropdownButtonFormField<TopupMethod>(
                  initialValue: _method,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.topupMethod, prefixIcon: const Icon(Icons.account_balance_wallet_outlined)),
                  items: [for (final m in methods) DropdownMenuItem(value: m, child: Text(m.name(context.lang)))],
                  validator: (v) => v == null ? l.vFieldRequired : null,
                  onChanged: (m) => setState(() => _method = m),
                ),
                const SizedBox(height: 14),
                AppTextField(controller: _reference, label: l.topupReference, icon: Icons.tag_rounded, textDirection: TextDirection.ltr),
                const SizedBox(height: 14),
                PhotoUploadTile(
                  title: l.topupProof,
                  subtitle: l.optional,
                  bucket: Buckets.topupProofs,
                  folder: 'proof',
                  currentPath: _proofPath,
                  onUploaded: (path) async => setState(() => _proofPath = path),
                ),
                const SizedBox(height: 22),
                PrimaryButton(label: l.send, icon: Icons.send_rounded, loading: _busy, onPressed: () => _submit(settings)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
