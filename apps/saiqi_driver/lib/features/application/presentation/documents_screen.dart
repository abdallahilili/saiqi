import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/core.dart';

/// Envoi des pièces : carte d'identité, permis, carte grise, assurance (facultative), photo.
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final docs = ref.watch(documentsProvider);
    final driver = ref.watch(myDriverProvider).value;
    final editable = driver != null && driver.status != DriverStatus.pending;

    return Scaffold(
      appBar: AppBar(title: Text(l.stepDocuments)),
      body: AsyncValueView<List<DriverDocument>>(
        value: docs,
        onRetry: () => ref.invalidate(documentsProvider),
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.documentsIntro, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 14),
            for (final type in DocumentType.values) ...[
              _DocTile(
                type: type,
                doc: list.where((d) => d.type == type).firstOrNull,
                enabled: editable,
                onUploaded: (path) async {
                  await ref.read(driverRepositoryProvider).saveDocument(type, path);
                },
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.type, required this.doc, required this.onUploaded, required this.enabled});

  final DocumentType type;
  final DriverDocument? doc;
  final bool enabled;
  final Future<void> Function(String path) onUploaded;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final required = requiredDocumentTypes.contains(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoUploadTile(
          title: l.documentTypeLabel(type),
          subtitle: required ? l.documentRequired : l.stepOptional,
          requiredField: required,
          bucket: Buckets.driverDocuments,
          folder: type.db,
          currentPath: doc?.filePath,
          enabled: enabled,
          badge: doc == null ? null : DocumentStatusBadge(doc!.status),
          onUploaded: onUploaded,
        ),
        if (doc?.status == DocumentStatus.rejected && doc?.rejectionReason != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: InfoBanner(
              icon: Icons.error_outline,
              color: AppColors.danger,
              message: l.docRejectedReason(doc!.rejectionReason!),
            ),
          ),
      ],
    );
  }
}
