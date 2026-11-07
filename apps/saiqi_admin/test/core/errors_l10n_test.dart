import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saiqi_admin/core/core.dart';
import 'package:saiqi_admin/core/l10n/gen/app_localizations_ar.dart';
import 'package:saiqi_admin/core/l10n/gen/app_localizations_fr.dart';

void main() {
  group('mapError', () {
    test('erreur métier SQL (P0001) -> code stable', () {
      final e = mapError(const PostgrestException(message: 'booking_not_available', code: 'P0001'));
      expect(e.code, 'booking_not_available');
    });

    test('insufficient_balance transporte required / balance', () {
      final e = mapError(const PostgrestException(
        message: 'insufficient_balance',
        code: 'P0001',
        details: 'required=150;balance=40',
      ));
      expect(e.code, 'insufficient_balance');
      expect(e.params, {'required': '150', 'balance': '40'});
      final msg = errorMessage(AppLocalizationsFr(), e);
      expect(msg, contains('40'));
      expect(msg, contains('150'));
    });

    test('permissions et doublons', () {
      expect(mapError(const PostgrestException(message: 'x', code: '42501')).code, 'permission_denied');
      expect(mapError(const PostgrestException(message: 'x', code: '23505')).code, 'duplicate');
    });

    test("erreurs d'authentification", () {
      expect(
        mapError(const AuthApiException('Invalid login credentials', code: 'invalid_credentials', statusCode: '400')).code,
        'invalid_credentials',
      );
      expect(
        mapError(const AuthApiException('User already registered', code: 'user_already_exists', statusCode: '422')).code,
        'phone_already_registered',
      );
      expect(mapError(const AuthApiException('Database error saving new user', statusCode: '500')).code, 'signup_failed');
    });

    test('réseau', () {
      expect(mapError(const SocketException('no route')).code, 'network_error');
      expect(mapError(TimeoutException('t')).isNetwork, isTrue);
    });

    test('guard retente sur erreur réseau puis réussit', () async {
      var calls = 0;
      final r = await guard(() async {
        calls++;
        if (calls < 3) throw const SocketException('x');
        return 'ok';
      }, retries: 3);
      expect(r, 'ok');
      expect(calls, 3);
    });

    test('guard ne retente pas une erreur métier', () async {
      var calls = 0;
      await expectLater(
        guard(() async {
          calls++;
          throw const PostgrestException(message: 'insufficient_balance', code: 'P0001');
        }, retries: 3),
        throwsA(isA<AppException>().having((e) => e.code, 'code', 'insufficient_balance')),
      );
      expect(calls, 1);
    });
  });

  group('l10n', () {
    Map<String, dynamic> arb(String lang) =>
        jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

    test('ar et fr ont exactement les mêmes clés', () {
      final ar = arb('ar').keys.where((k) => !k.startsWith('@')).toSet();
      final fr = arb('fr').keys.where((k) => !k.startsWith('@')).toSet();
      expect(ar.difference(fr), isEmpty, reason: 'clés manquantes en français');
      expect(fr.difference(ar), isEmpty, reason: 'clés manquantes en arabe');
    });

    test("chaque code d'erreur du SQL a un message localisé", () {
      const codes = [
        'not_authenticated', 'not_client', 'driver_not_available', 'service_not_offered', 'pickup_required',
        'invalid_schedule', 'too_many_passengers', 'booking_not_found', 'booking_not_available', 'booking_expired',
        'offer_not_available', 'insufficient_balance', 'driver_not_approved', 'wallet_not_found',
        'invalid_transition', 'not_allowed', 'booking_not_cancellable', 'cancel_not_allowed_after_en_route',
        'contact_not_available', 'amount_too_low', 'booking_not_completed', 'already_reviewed',
        'application_incomplete', 'reason_required', 'admin_forbidden', 'topup_already_reviewed',
        'invalid_phone', 'phone_already_registered', 'network_error', 'wrong_app_role',
      ];
      final fr = AppLocalizationsFr();
      final ar = AppLocalizationsAr();
      for (final c in codes) {
        expect(fr.errorForCode(c), isNotNull, reason: 'fr: $c');
        expect(ar.errorForCode(c), isNotNull, reason: 'ar: $c');
      }
      expect(fr.errorForCode('code_inconnu'), isNull);
      expect(errorMessage(fr, StateError('boom')), fr.err_unknown);
    });

    test("libellés d'énumérations complets", () {
      final fr = AppLocalizationsFr();
      for (final s in BookingStatus.values) {
        expect(fr.bookingStatusLabel(s), isNotEmpty);
      }
      for (final t in DocumentType.values) {
        expect(fr.documentTypeLabel(t), isNotEmpty);
      }
      expect(fr.bookingStatusLabel(BookingStatus.enRoute), 'Chauffeur en route');
      expect(AppLocalizationsAr().weekdayLabel(1), 'الإثنين');
    });
  });
}
