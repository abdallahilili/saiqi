import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache léger pour réseau faible : on sert la dernière réponse connue quand le réseau échoue.
class JsonCache {
  JsonCache(this._prefs);
  final SharedPreferences _prefs;

  static const _prefix = 'cache.v1.';

  Future<void> write(String key, Object? value) => _prefs.setString('$_prefix$key', jsonEncode(value));

  Object? read(String key) {
    final raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await _prefs.remove(k);
    }
  }

  /// Essaie le réseau puis écrit le cache ; en cas d'échec réseau, renvoie le cache s'il existe.
  Future<T> fetch<T>({
    required String key,
    required Future<Object?> Function() loader,
    required T Function(Object? json) parse,
  }) async {
    try {
      final fresh = await loader();
      await write(key, fresh);
      return parse(fresh);
    } catch (e) {
      final cached = read(key);
      if (cached != null) return parse(cached);
      rethrow;
    }
  }
}
