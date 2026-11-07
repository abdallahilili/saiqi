import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

final _auditProvider = FutureProvider.autoDispose<List<AuditLog>>((ref) => ref.watch(adminRepositoryProvider).auditLogs());

String auditActionLabel(AppLocalizations l, String action) => switch (action) {
      'approve_driver' => l.audit_approve_driver,
      'reject_driver' => l.audit_reject_driver,
      'review_document' => l.audit_review_document,
      'set_driver_status' => l.audit_set_driver_status,
      'set_account_status' => l.audit_set_account_status,
      'set_admin_role' => l.audit_set_admin_role,
      'review_topup' => l.audit_review_topup,
      'adjust_wallet' => l.audit_adjust_wallet,
      'create_booking' => l.audit_create_booking,
      'reassign_booking' => l.audit_reassign_booking,
      'cancel_booking' => l.audit_cancel_booking,
      'handle_complaint' => l.audit_handle_complaint,
      'moderate_review' => l.audit_moderate_review,
      'send_announcement' => l.audit_send_announcement,
      'reset_password' => l.audit_reset_password,
      'create_admin' => l.audit_create_admin,
      'warn_user' => l.audit_warn_user,
      'insert' => l.audit_insert,
      'update' => l.audit_update,
      'delete' => l.audit_delete,
      _ => action,
    };

/// Journal d'audit (super_admin) : qui a fait quoi, quand.
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final logs = ref.watch(_auditProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.auditTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_auditProvider),
        child: AsyncValueView<List<AuditLog>>(
          value: logs,
          onRetry: () => ref.invalidate(_auditProvider),
          isEmpty: (list) => list.isEmpty,
          emptyTitle: l.noAudit,
          emptyIcon: Icons.fact_check_outlined,
          data: (list) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final a = list[i];
              return Card(
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  leading: const CircleAvatar(child: Icon(Icons.history_rounded)),
                  title: Text(auditActionLabel(l, a.action), style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${a.entity} · ${a.actorName != null ? l.by(a.actorName!) : '—'}\n${Fmt.dateTime(a.createdAt, context.lang)}'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (a.entityId != null) SelectableText(a.entityId!, style: const TextStyle(fontSize: 11.5)),
                    if (a.payload.isNotEmpty)
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: SelectableText(const JsonEncoder.withIndent('  ').convert(a.payload), style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
