import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:saiqi_admin/core/core.dart';

void main() {
  setUpAll(() async => initializeDateFormatting());

  test('montants MRU entiers', () {
    expect(Fmt.number(1500, 'en'), '1,500');
    expect(Fmt.mru(300, 'fr'), '300 MRU');
    expect(Fmt.mru(300, 'ar'), '300 أوقية');
    expect(Fmt.number(1500, 'fr').replaceAll(RegExp(r'\s'), ' '), '1 500');
    expect(Fmt.signedMru(-150, 'fr'), '−150 MRU');
    expect(Fmt.signedMru(150, 'fr'), '+150 MRU');
    expect(Fmt.signedMru(0, 'fr'), '0 MRU');
  });

  test('compte à rebours mm:ss, jamais négatif', () {
    expect(Fmt.countdown(const Duration(minutes: 9, seconds: 5)), '09:05');
    expect(Fmt.countdown(const Duration(seconds: -30)), '00:00');
  });

  test('pourcentage de commission', () {
    expect(Fmt.percent(0.10), '10%');
    expect(Fmt.percent(0.125), '12.5%');
  });

  test("dates en chiffres latins pour l'arabe", () {
    final d = DateTime(2026, 3, 5, 14, 30);
    expect(Fmt.time(d, 'ar'), '14:30');
    expect(Fmt.date(d, 'ar'), contains('2026'));
    expect(Fmt.date(d, 'fr'), contains('2026'));
  });
}
