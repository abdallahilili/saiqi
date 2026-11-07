import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

final _complaintsProvider = FutureProvider.autoDispose.family<List<Complaint>, ComplaintStatus?>((ref, status) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).listComplaints(status: status);
});

final _reviewsAdminProvider = FutureProvider.autoDispose<List<Review>>((ref) {
  ref.watch(adminLiveTickProvider);
  return ref.watch(adminRepositoryProvider).listReviews();
});

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  ComplaintStatus? _status = ComplaintStatus.open;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final complaints = ref.watch(_complaintsProvider(_status));
    return Scaffold(
      appBar: AppBar(title: Text(l.complaintsTitle)),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final s in <ComplaintStatus?>[ComplaintStatus.open, ComplaintStatus.inReview, ComplaintStatus.resolved, ComplaintStatus.dismissed, null])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(label: Text(s == null ? l.all : l.complaintStatusLabel(s)), selected: _status == s, onSelected: (_) => setState(() => _status = s)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Complaint>>(
              value: complaints,
              onRetry: () => ref.invalidate(_complaintsProvider(_status)),
              isEmpty: (list) => list.isEmpty,
              emptyTitle: l.noComplaints,
              emptyIcon: Icons.report_gmailerrorred_outlined,
              data: (list) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = list[i];
                  return Card(
                    child: ListTile(
                      title: Row(children: [
                        Expanded(child: Text(c.authorName ?? '—', style: const TextStyle(fontWeight: FontWeight.w800))),
                        ComplaintStatusBadge(c.status),
                      ]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(c.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(Fmt.dateTime(c.createdAt, context.lang), style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => _ComplaintSheet(complaint: c, onChanged: () => ref.invalidate(_complaintsProvider(_status))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintSheet extends ConsumerStatefulWidget {
  const _ComplaintSheet({required this.complaint, required this.onChanged});
  final Complaint complaint;
  final VoidCallback onChanged;

  @override
  ConsumerState<_ComplaintSheet> createState() => _ComplaintSheetState();
}

class _ComplaintSheetState extends ConsumerState<_ComplaintSheet> {
  late final TextEditingController _resolution = TextEditingController(text: widget.complaint.resolution ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _resolution.dispose();
    super.dispose();
  }

  Future<void> _setStatus(ComplaintStatus s) async {
    final l = context.l10n;
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).handleComplaint(widget.complaint.id, s, resolution: _resolution.text.trim()),
      successMessage: l.complaintUpdatedMsg,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      widget.onChanged();
      Navigator.of(context).pop();
    }
  }

  Future<void> _sanction(AccountStatus status) async {
    final l = context.l10n;
    final id = widget.complaint.againstId;
    if (id == null) return;
    final reason = await promptTextDialog(context, title: l.reason, hint: l.reasonHint);
    if (reason == null || !mounted) return;
    await runAction(context, () => ref.read(adminRepositoryProvider).setAccountStatus(id, status, reason: reason), successMessage: l.accountStatusChanged);
  }

  Future<void> _warn() async {
    final l = context.l10n;
    final id = widget.complaint.againstId;
    if (id == null) return;
    final msg = await promptTextDialog(context, title: l.warnUser, hint: l.warnMessageHint);
    if (msg == null || !mounted) return;
    await runAction(context, () => ref.read(adminRepositoryProvider).warnUser(id, msg), successMessage: l.warnSentMsg);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = widget.complaint;
    final perms = ref.watch(permsProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(l.complaintDetail, style: Theme.of(context).textTheme.titleLarge)),
              ComplaintStatusBadge(c.status),
            ]),
            const SizedBox(height: 12),
            InfoRow(label: l.complaintAuthor, value: c.authorName),
            InfoRow(label: l.complaintAgainst, value: c.againstName),
            InfoRow(label: l.status, value: Fmt.dateTime(c.createdAt, context.lang)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: Text(c.text),
            ),
            if (c.bookingId != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.bookingDetail),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/booking/${c.bookingId}');
                  },
                ),
              ),
            if (perms.canHandleComplaints) ...[
              const SizedBox(height: 12),
              AppTextField(controller: _resolution, label: l.resolutionField, icon: Icons.gavel_outlined, maxLines: 3),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: _busy ? null : () => _setStatus(ComplaintStatus.inReview), child: Text(l.markInReview)),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(0, 48)),
                    onPressed: _busy ? null : () => _setStatus(ComplaintStatus.resolved),
                    child: Text(l.resolveComplaint),
                  ),
                  OutlinedButton(onPressed: _busy ? null : () => _setStatus(ComplaintStatus.dismissed), child: Text(l.dismissComplaint)),
                ],
              ),
              if (c.againstId != null) ...[
                const Divider(height: 28),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(icon: const Icon(Icons.campaign_outlined), label: Text(l.warnUser), onPressed: _warn),
                    OutlinedButton.icon(icon: const Icon(Icons.pause_circle_outline), label: Text(l.suspendAccount), onPressed: () => _sanction(AccountStatus.suspended)),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                      icon: const Icon(Icons.block_rounded),
                      label: Text(l.blockAccount),
                      onPressed: () => _sanction(AccountStatus.blocked),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Modération des avis : masquer / afficher (un avis masqué sort de la note moyenne).
class ReviewsModerationScreen extends ConsumerWidget {
  const ReviewsModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final reviews = ref.watch(_reviewsAdminProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.reviewsModeration)),
      body: AsyncValueView<List<Review>>(
        value: reviews,
        onRetry: () => ref.invalidate(_reviewsAdminProvider),
        isEmpty: (list) => list.isEmpty,
        emptyTitle: l.noReviewsAdmin,
        emptyIcon: Icons.reviews_outlined,
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = list[i];
            return Card(
              color: r.isHidden ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      StarRating(value: r.rating.toDouble(), size: 18),
                      const Spacer(),
                      if (r.isHidden) StatusBadge(label: l.reviewHidden, color: AppColors.neutral, dense: true),
                    ]),
                    const SizedBox(height: 6),
                    Text(l.reviewFor(r.driverName ?? '—'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (r.reviewerName != null) Text(r.reviewerName!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12.5)),
                    if (r.comment != null && r.comment!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.comment!)),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        icon: Icon(r.isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        label: Text(r.isHidden ? l.showReview : l.hideReview),
                        onPressed: () async {
                          final ok = await runAction(context, () => ref.read(adminRepositoryProvider).moderateReview(r.id, hidden: !r.isHidden));
                          if (ok) ref.invalidate(_reviewsAdminProvider);
                        },
                      ),
                    ),
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
