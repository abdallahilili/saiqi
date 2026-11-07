import 'package:supabase_flutter/supabase_flutter.dart';

/// URLs publiques des buckets en lecture publique (avatars, photos de véhicule).
class StorageUrls {
  const StorageUrls._();

  static String _public(String bucket, String path) {
    if (path.startsWith('http')) return path;
    return Supabase.instance.client.storage.from(bucket).getPublicUrl(path);
  }

  static String vehiclePhoto(String path) => _public('vehicle-photos', path);
  static String avatar(String path) => _public('avatars', path);
}
