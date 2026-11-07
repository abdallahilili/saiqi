import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/gen/app_localizations.dart';
import '../l10n/l10n_labels.dart';

/// Erreur applicative unifiée : `code` est un identifiant stable traduit via l10n (`err_<code>`).
class AppException implements Exception {
  const AppException(this.code, {this.details, this.cause});

  final String code;

  /// Paramètres éventuels sous la forme `cle=valeur;cle2=valeur2` (ex. `required=150;balance=40`).
  final String? details;
  final Object? cause;

  Map<String, String> get params {
    final out = <String, String>{};
    for (final part in (details ?? '').split(';')) {
      final i = part.indexOf('=');
      if (i > 0) out[part.substring(0, i).trim()] = part.substring(i + 1).trim();
    }
    return out;
  }

  bool get isNetwork => code == 'network_error';

  @override
  String toString() => 'AppException($code${details == null ? '' : ', $details'})';
}

/// Convertit n'importe quelle erreur (Postgrest, Auth, Storage, Functions, réseau) en [AppException].
AppException mapError(Object e) {
  if (e is AppException) return e;

  if (e is SocketException || e is TimeoutException || e is http.ClientException || e is HandshakeException) {
    return AppException('network_error', cause: e);
  }
  if (e is AuthRetryableFetchException) return AppException('network_error', cause: e);

  if (e is AuthException) {
    final msg = e.message.toLowerCase();
    final code = (e.code ?? '').toLowerCase();
    if (code == 'invalid_credentials' || msg.contains('invalid login credentials')) {
      return AppException('invalid_credentials', cause: e);
    }
    if (code == 'user_already_exists' || code == 'email_exists' || msg.contains('already registered')) {
      return AppException('phone_already_registered', cause: e);
    }
    if (code == 'weak_password' || msg.contains('at least')) return AppException('password_too_short', cause: e);
    if (code.contains('rate_limit') || e.statusCode == '429') return AppException('rate_limited', cause: e);
    if (msg.contains('database error saving new user')) return AppException('signup_failed', cause: e);
    if (msg.contains('jwt') || msg.contains('session')) return AppException('session_expired', cause: e);
    return AppException('unknown', details: e.message, cause: e);
  }

  if (e is PostgrestException) {
    if (e.code == 'P0001') return AppException(e.message, details: e.details?.toString(), cause: e);
    switch (e.code) {
      case '42501':
        return AppException('permission_denied', cause: e);
      case '23505':
        return AppException('duplicate', cause: e);
      case 'PGRST301':
      case 'PGRST303':
        return AppException('session_expired', cause: e);
    }
    return AppException('unknown', details: e.message, cause: e);
  }

  if (e is FunctionException) {
    final d = e.details;
    if (d is Map && d['error'] is String) return AppException(d['error'] as String, cause: e);
    return AppException('unknown', cause: e);
  }

  if (e is StorageException) return AppException('upload_failed', details: e.message, cause: e);

  return AppException('unknown', details: e.toString(), cause: e);
}

/// Message affichable à l'utilisateur dans sa langue.
String errorMessage(AppLocalizations l, Object error) {
  final ex = mapError(error);
  if (ex.code == 'insufficient_balance') {
    final p = ex.params;
    if (p['required'] != null && p['balance'] != null) {
      return l.err_insufficient_balance_detail(p['balance']!, p['required']!);
    }
  }
  return l.errorForCode(ex.code) ?? l.err_unknown;
}

bool _isTransient(Object e) {
  final ex = mapError(e);
  return ex.code == 'network_error';
}

/// Exécute [action] en convertissant les erreurs ; relance jusqu'à [retries] fois sur erreur réseau
/// (réseau faible). N'utiliser le retry que pour des opérations idempotentes (lectures, uploads).
Future<T> guard<T>(Future<T> Function() action, {int retries = 0}) async {
  var attempt = 0;
  while (true) {
    try {
      return await action();
    } catch (e) {
      if (attempt < retries && _isTransient(e)) {
        attempt++;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
        continue;
      }
      throw mapError(e);
    }
  }
}
