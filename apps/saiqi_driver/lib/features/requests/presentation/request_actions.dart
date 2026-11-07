import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Accepte une demande : la commission est déduite côté SQL (atomique). Ouvre la course si réussi.
Future<void> acceptIncoming(BuildContext context, WidgetRef ref, IncomingRequest request) async {
  final l = context.l10n;
  try {
    await ref.read(bookingRepositoryProvider).accept(request.bookingId);
    ref.invalidate(incomingRequestsProvider);
    if (!context.mounted) return;
    showAppSnack(context, l.requestAccepted);
    context.go('/home');
    unawaited(context.push('/trip/${request.bookingId}'));
  } on AppException catch (e) {
    if (!context.mounted) return;
    if (e.code == 'insufficient_balance') {
      showErrorSnack(context, e);
      unawaited(context.push('/topup'));
    } else {
      showErrorSnack(context, e);
      if (e.code == 'booking_not_available' || e.code == 'booking_expired' || e.code == 'offer_not_available') {
        ref.invalidate(incomingRequestsProvider);
      }
    }
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
  }
}

Future<bool> rejectIncoming(BuildContext context, WidgetRef ref, IncomingRequest request) async {
  final l = context.l10n;
  final ok = await confirmDialog(context, title: l.rejectRequest, message: l.rejectConfirm, destructive: true, confirmLabel: l.rejectRequest);
  if (!ok || !context.mounted) return false;
  final done = await runAction(context, () async {
    await ref.read(bookingRepositoryProvider).reject(request.bookingId);
    ref.invalidate(incomingRequestsProvider);
  }, successMessage: l.requestRejectedMsg);
  return done;
}

/// Carte d'une demande entrante : détails, commission, compte à rebours, accepter / refuser.
class IncomingRequestCard extends ConsumerStatefulWidget {
  const IncomingRequestCard({super.key, required this.request, this.detailed = false});

  final IncomingRequest request;

  /// Mode détail : sans bouton « voir le détail », bloc d'explications complet.
  final bool detailed;

  @override
  ConsumerState<IncomingRequestCard> createState() => _IncomingRequestCardState();
}

class _IncomingRequestCardState extends ConsumerState<IncomingRequestCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final r = widget.request;
    final wallet = ref.watch(walletProvider).value;
    final balance = wallet?.balance ?? 0;
    final blocked = balance < r.commissionAmount;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.serviceName(lang), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
                CountdownChip(expiresAt: r.expiresAt, onExpired: () => ref.invalidate(incomingRequestsProvider)),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                StatusBadge(label: r.cityName(lang), color: AppColors.info, icon: Icons.place_outlined, dense: true),
                StatusBadge(label: l.channelLabel(r.channel), color: AppColors.neutral, dense: true),
              ],
            ),
            const SizedBox(height: 12),
            RouteLines(pickup: r.pickupText, dropoff: r.dropoffText),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(Fmt.dateTime(r.scheduledAt, lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.people_outline, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${r.passengers}'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(child: Text(r.clientName)),
              ],
            ),
            if (r.notes != null && r.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r.notes!)),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.agreedPrice, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                      MoneyText(r.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l.commissionLabel} (${Fmt.percent(r.commissionRate)})', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                      MoneyText(r.commissionAmount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.error)),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.detailed) ...[
              const SizedBox(height: 12),
              Text(l.commissionNotice(Fmt.mru(r.commissionAmount, lang), Fmt.percent(r.commissionRate)),
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              if (!blocked) ...[
                const SizedBox(height: 4),
                Text(l.balanceAfterAccept(Fmt.mru(balance - r.commissionAmount, lang)), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
              const SizedBox(height: 4),
              Text(l.clientPaysDriver, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5)),
            ],
            const SizedBox(height: 14),
            if (blocked) ...[
              InfoBanner(
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.danger,
                message: l.insufficientBalanceBlock(Fmt.mru(balance, lang), Fmt.mru(r.commissionAmount, lang)),
              ),
              const SizedBox(height: 10),
              PrimaryButton(label: l.rechargeToAccept, icon: Icons.add_card_rounded, onPressed: () => context.push('/topup')),
              const SizedBox(height: 8),
              DangerButton(label: l.rejectRequest, onPressed: _busy ? null : _reject),
            ] else
              Row(
                children: [
                  Expanded(child: DangerButton(label: l.rejectRequest, onPressed: _busy ? null : _reject)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: l.acceptRequest,
                      icon: Icons.check_rounded,
                      loading: _busy,
                      onPressed: () async {
                        setState(() => _busy = true);
                        await acceptIncoming(context, ref, r);
                        if (mounted) setState(() => _busy = false);
                      },
                    ),
                  ),
                ],
              ),
            if (!widget.detailed) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(onPressed: () => context.push('/request/${r.bookingId}'), child: Text(l.details)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    final done = await rejectIncoming(context, ref, widget.request);
    if (!mounted) return;
    setState(() => _busy = false);
    if (done && widget.detailed) context.pop();
  }
}
