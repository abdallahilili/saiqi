import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_exception.dart';

class Buckets {
  const Buckets._();
  static const driverDocuments = 'driver-documents'; // privé
  static const topupProofs = 'topup-proofs'; // privé
  static const vehiclePhotos = 'vehicle-photos'; // public
  static const avatars = 'avatars'; // public

  static const publicBuckets = {vehiclePhotos, avatars};
}

/// Upload d'images avec compression préalable (économie de données) et retry réseau.
/// Les chemins sont toujours de la forme `<user_id>/<dossier>/<horodatage>.jpg` (exigé par les policies Storage).
class StorageRepository {
  StorageRepository(this._db);
  final SupabaseClient _db;

  Future<XFile?> pick({required bool camera}) {
    return ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 2200,
      maxHeight: 2200,
      imageQuality: 92,
    );
  }

  Future<Uint8List> _compress(XFile file) async {
    try {
      final out = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 1600,
        minHeight: 1600,
        quality: 80,
        format: CompressFormat.jpeg,
      );
      if (out != null && out.isNotEmpty) return out;
    } catch (_) {
      // plateformes sans compression native : on envoie l'original
    }
    return file.readAsBytes();
  }

  /// Compresse puis envoie ; renvoie le chemin dans le bucket.
  Future<String> uploadImage({
    required String bucket,
    required String folder,
    required XFile file,
  }) =>
      guard(() async {
        final uid = _db.auth.currentUser?.id;
        if (uid == null) throw const AppException('not_authenticated');
        final bytes = await _compress(file);
        final path = '$uid/$folder/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _db.storage.from(bucket).uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
        return path;
      }, retries: 2);

  String publicUrl(String bucket, String path) => _db.storage.from(bucket).getPublicUrl(path);

  /// URL affichable : publique pour les buckets publics, signée (1 h) pour les privés.
  Future<String> urlFor(String bucket, String path) => guard(() async {
        if (path.startsWith('http')) return path;
        if (Buckets.publicBuckets.contains(bucket)) return publicUrl(bucket, path);
        return _db.storage.from(bucket).createSignedUrl(path, 3600);
      }, retries: 1);

  Future<void> remove(String bucket, String path) => guard(() async {
        await _db.storage.from(bucket).remove([path]);
      });
}
