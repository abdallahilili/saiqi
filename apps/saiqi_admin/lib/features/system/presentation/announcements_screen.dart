import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

final _announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((ref) => ref.watch(adminRepositoryProvider).announcements());

/// Annonces : notification envoyée à tous les chauffeurs, tous les clients ou à tout le monde.
class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final list = ref.watch(_announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.announcementsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.campaign_outlined),
        label: Text(l.newAnnouncement),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => _ComposeSheet(onSent: () => ref.invalidate(_announcementsProvider)),
        ),
      ),
      body: AsyncValueView<List<Announcement>>(
        value: list,
        onRetry: () => ref.invalidate(_announcementsProvider),
        isEmpty: (l) => l.isEmpty,
        emptyTitle: l.noAnnouncements,
        emptyIcon: Icons.campaign_outlined,
        data: (items) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final a = items[i];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.body),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, children: [
                      StatusBadge(label: l.audienceLabel(a.audience), color: AppColors.info, dense: true),
                      StatusBadge(label: l.recipientsCount('${a.recipientsCount}'), color: AppColors.neutral, dense: true),
                    ]),
                    const SizedBox(height: 4),
                    Text(Fmt.dateTime(a.createdAt, context.lang), style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ComposeSheet extends ConsumerStatefulWidget {
  const _ComposeSheet({required this.onSent});
  final VoidCallback onSent;

  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _audience = 'drivers';
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = context.l10n;
    if (!(_form.currentState?.validate() ?? false)) return;
    final ok = await confirmDialog(context, title: l.newAnnouncement, message: l.audienceLabel(_audience));
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final done = await runAction(
      context,
      () => ref.read(adminRepositoryProvider).sendAnnouncement(audience: _audience, title: _title.text.trim(), body: _body.text.trim()),
      successMessage: l.announcementSentMsg,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (done) {
      widget.onSent();
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
              Text(l.newAnnouncement, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _audience,
                decoration: InputDecoration(labelText: l.audienceField, prefixIcon: const Icon(Icons.groups_outlined)),
                items: [for (final a in const ['drivers', 'clients', 'all']) DropdownMenuItem(value: a, child: Text(l.audienceLabel(a)))],
                onChanged: (v) => setState(() => _audience = v ?? 'drivers'),
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _title, label: l.announcementTitleField, validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null),
              const SizedBox(height: 12),
              AppTextField(controller: _body, label: l.announcementBodyField, maxLines: 4, validator: (v) => (v == null || v.trim().isEmpty) ? l.vFieldRequired : null),
              const SizedBox(height: 20),
              PrimaryButton(label: l.send, icon: Icons.send_rounded, loading: _busy, onPressed: _send),
            ],
          ),
        ),
      ),
    );
  }
}
