import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final wallet = ref.watch(walletProvider);
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.empty;
    final txs = ref.watch(walletTxProvider);
    final topups = ref.watch(topupsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.wallet)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(walletTxProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AsyncValueView<Wallet?>(
              value: wallet,
              onRetry: () => ref.invalidate(walletProvider),
              data: (w) {
                final balance = w?.balance ?? 0;
                final low = balance < settings.lowBalanceThreshold;
                return Column(
                  children: [
                    Card(
                      color: scheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.walletBalance, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85))),
                            const SizedBox(height: 4),
                            MoneyText(balance, style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: scheme.onPrimary)),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(46)),
                              onPressed: () => context.push('/topup'),
                              icon: const Icon(Icons.add_card_rounded),
                              label: Text(l.requestTopup),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (low) ...[
                      const SizedBox(height: 10),
                      InfoBanner(icon: Icons.warning_amber_rounded, color: AppColors.warning, message: l.lowBalanceWarning),
                    ],
                    const SizedBox(height: 10),
                    InfoBanner(icon: Icons.info_outline, message: l.howCommissionWorks),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),
            Text(l.topupRequests, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            topups.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: LoadingView()),
              error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(topupsProvider)),
              data: (list) => list.isEmpty
                  ? Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.noTopups)))
                  : Column(
                      children: [
                        for (final t in list.take(5))
                          Card(
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.add_card_rounded)),
                              title: MoneyText(t.amount, style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text('${t.method} · ${Fmt.dateTime(t.createdAt, lang)}${t.reviewNote != null ? '\n${t.reviewNote}' : ''}'),
                              isThreeLine: t.reviewNote != null,
                              trailing: TopupStatusBadge(t.status),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 22),
            Text(l.transactions, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            txs.when(
              loading: () => const Padding(padding: EdgeInsets.all(16), child: LoadingView()),
              error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(walletTxProvider)),
              data: (list) => list.isEmpty
                  ? Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.noTransactions)))
                  : Column(
                      children: [
                        for (final tx in list)
                          Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (tx.amount >= 0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.14),
                                child: Icon(tx.amount >= 0 ? Icons.south_west_rounded : Icons.north_east_rounded,
                                    color: tx.amount >= 0 ? AppColors.success : AppColors.danger),
                              ),
                              title: Text(l.txTypeLabel(tx.type), style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${Fmt.dateTime(tx.createdAt, lang)}\n${l.balanceAfterTx(Fmt.mru(tx.balanceAfter, lang))}'),
                              isThreeLine: true,
                              trailing: MoneyText(tx.amount,
                                  signed: true,
                                  style: TextStyle(fontWeight: FontWeight.w900, color: tx.amount >= 0 ? AppColors.success : AppColors.danger)),
                              onTap: tx.bookingId == null ? null : () => context.push('/trip/${tx.bookingId}'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
