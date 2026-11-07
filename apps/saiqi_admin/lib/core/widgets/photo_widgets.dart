import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../errors/app_exception.dart';
import '../l10n/l10n.dart';
import '../providers/core_providers.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'state_views.dart';

/// Choix caméra / galerie. Renvoie null si annulé.
Future<XFile?> pickImageSheet(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final camera = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l.takePhoto),
            onTap: () => Navigator.pop(ctx, true),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l.fromGallery),
            onTap: () => Navigator.pop(ctx, false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (camera == null) return null;
  try {
    return await ref.read(storageRepositoryProvider).pick(camera: camera);
  } catch (e) {
    if (context.mounted) showErrorSnack(context, mapError(e));
    return null;
  }
}

/// Tuile d'envoi d'une image (document, preuve, photo) : choisir -> compresser -> envoyer.
class PhotoUploadTile extends ConsumerStatefulWidget {
  const PhotoUploadTile({
    super.key,
    required this.title,
    required this.bucket,
    required this.folder,
    required this.onUploaded,
    this.currentPath,
    this.badge,
    this.requiredField = false,
    this.subtitle,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final String bucket;
  final String folder;
  final String? currentPath;
  final Widget? badge;
  final bool requiredField;
  final bool enabled;

  /// Appelé avec le chemin de l'objet dans le bucket une fois l'envoi réussi.
  final Future<void> Function(String path) onUploaded;

  @override
  ConsumerState<PhotoUploadTile> createState() => _PhotoUploadTileState();
}

class _PhotoUploadTileState extends ConsumerState<PhotoUploadTile> {
  bool _busy = false;

  Future<void> _pick() async {
    final file = await pickImageSheet(context, ref);
    if (file == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final path = await ref.read(storageRepositoryProvider).uploadImage(
            bucket: widget.bucket,
            folder: widget.folder,
            file: file,
          );
      await widget.onUploaded(path);
      if (mounted) showAppSnack(context, context.l10n.photoUploaded);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final has = widget.currentPath != null && widget.currentPath!.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (has ? AppColors.success : scheme.outline).withValues(alpha: 0.15),
              child: Icon(has ? Icons.check_rounded : Icons.upload_file_outlined,
                  color: has ? AppColors.success : scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.requiredField ? '${widget.title} *' : widget.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle ?? (has ? l.documentUploaded : l.documentMissing),
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                  ),
                  if (widget.badge != null) ...[const SizedBox(height: 6), widget.badge!],
                ],
              ),
            ),
            if (has)
              IconButton(
                tooltip: l.documentView,
                icon: const Icon(Icons.visibility_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => ImageViewerPage(title: widget.title, bucket: widget.bucket, path: widget.currentPath!),
                )),
              ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4)),
              )
            else
              IconButton.filledTonal(
                tooltip: has ? l.documentReplace : l.pickPhoto,
                icon: Icon(has ? Icons.refresh : Icons.add_a_photo_outlined),
                onPressed: widget.enabled ? _pick : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// Visionneuse plein écran avec zoom (pincer / double-tap) pour documents et preuves.
class ImageViewerPage extends ConsumerWidget {
  const ImageViewerPage({super.key, required this.title, required this.bucket, required this.path});

  final String title;
  final String bucket;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final url = ref.watch(_signedUrlProvider((bucket, path)));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: url.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_signedUrlProvider((bucket, path)))),
        data: (u) => Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 6,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: u,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const LoadingView(),
                    errorWidget: (_, _, _) => Center(
                      child: Text(l.imageLoadFailed, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Text(l.pinchToZoom, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _signedUrlProvider = FutureProvider.autoDispose.family<String, (String, String)>((ref, args) {
  return ref.watch(storageRepositoryProvider).urlFor(args.$1, args.$2);
});
