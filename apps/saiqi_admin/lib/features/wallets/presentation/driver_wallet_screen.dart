import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

final _adminDriverWalletProvider = FutureProvider.autoDispose.family<(AdminDriver, Wallet?, List<WalletTx>), String>((ref, driverId) async {
  ref.watch(adminLiveTickProvider);
  final repo = ref.watch(adminRepositoryProvider);
  final driver = await repo.getDriver(driverId);
  final wallet = await repo.driverWallet(driverId);
  final txs = wallet == null ? <WalletTx>[] : await repo.walletTransactions(wallet.id);
  return (driver, wallet, txs);
});

/// Solde et historique d'un chauffeur + ajustement manuel (super_admin) avec motif obligatoire.
class DriverWalletScreen extends ConsumerWidget {
  const DriverWalletScreen({super.key, required this.driverId});
  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final data = ref.watch(_adminDriverWalletProvider(driverId));
    final perms = ref.watch(permsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.walletHistory)),
      body: AsyncValueView<(AdminDriver, Wallet?, List<WalletTx>)>(
        value: data,
        onRetry: () => ref.invalidate(_adminDriverWalletProvider(driverId)),
        data: (r) {
          final (driver, wallet, txs) = r;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        UserAvatar(url: driver.avatarUrl, name: driver.displayName, radius: 22),
                        const SizedBox(width: 12),
                        Expanded(child: Text(driver.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                      ]),
                      const SizedBox(height: 14),
                      Text(l.walletBalance, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      MoneyText(wallet?.balance ?? 0, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                      if (wallet != null && perms.canAdjustWallet) ...[
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: l.adjustWallet,
                          icon: Icons.tune_rounded,
                          onPressed: () => _adjust(context, ref, wallet.balance),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.transactions, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (txs.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.noTransactions))),
              for (final tx in txs)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (tx.amount >= 0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.14),
                      child: Icon(tx.amount >= 0 ? Icons.south_west_rounded : Icons.north_east_rounded, color: tx.amount >= 0 ? AppColors.success : AppColors.danger),
                    ),
                    title: Text(l.txTypeLabel(tx.type), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${Fmt.dateTime(tx.createdAt, context.lang)}${tx.note != null ? '\n${tx.note}' : ''}\n${l.balanceAfterTx(Fmt.mru(tx.balanceAfter, context.lang))}'),
                    isThreeLine: true,
                    trailing: MoneyText(tx.amount, signed: true, style: TextStyle(fontWeight: FontWeight.w900, color: tx.amount >= 0 ? AppColors.success : AppColors.danger)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _adjust(BuildContext context, WidgetRef ref, int balance) async {
    final l = context.l10n;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.adjustWallet),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.adjustAmountHint, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 10),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                textDirection: TextDirection.ltr,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9]'))],
                decoration: InputDecoration(labelText: l.currencyMru),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n == 0) return l.vNumberInvalid;
                  if (balance + n < 0) return l.err_insufficient_balance;
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: noteCtrl,
                decoration: InputDecoration(labelText: l.adjustNote),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () {
              if (form.currentState?.validate() ?? false) Navigator.pop(ctx, true);
            },
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    final amount = int.tryParse(amountCtrl.text.trim());
    final note = noteCtrl.text.trim();
    amountCtrl.dispose();
    noteCtrl.dispose();
    if (ok != true || amount == null || !context.mounted) return;
    final done = await runAction(context, () => ref.read(adminRepositoryProvider).adjustWallet(driverId, amount, note), successMessage: l.adjustDone);
    if (done) ref.invalidate(_adminDriverWalletProvider(driverId));
  }
}
