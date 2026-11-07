import 'package:flutter_test/flutter_test.dart';

import 'package:saiqi_client/core/core.dart';

void main() {
  group('PhoneUtils.normalize', () {
    test('accepte 8 chiffres, +222, 222 et 00222', () {
      expect(PhoneUtils.normalize('36123456'), '+22236123456');
      expect(PhoneUtils.normalize('+222 36 12 34 56'), '+22236123456');
      expect(PhoneUtils.normalize('22236123456'), '+22236123456');
      expect(PhoneUtils.normalize('0022236123456'), '+22236123456');
      expect(PhoneUtils.normalize('36-12-34-56'), '+22236123456');
    });

    test("accepte l'exemple du cahier des charges", () {
      expect(PhoneUtils.normalize('22212345678'), '+22212345678');
    });

    test('rejette les numéros invalides', () {
      expect(PhoneUtils.normalize(null), isNull);
      expect(PhoneUtils.normalize(''), isNull);
      expect(PhoneUtils.normalize('123'), isNull);
      expect(PhoneUtils.normalize('abc'), isNull);
      expect(PhoneUtils.normalize('+33612345678'), isNull);
      expect(PhoneUtils.isValid('3612345'), isFalse);
    });
  });

  test('email technique dérivé du numéro normalisé', () {
    expect(PhoneUtils.technicalEmail('+22236123456'), '22236123456@saiqi.app');
    expect(PhoneUtils.technicalEmail(PhoneUtils.normalize('22212345678')!), '22212345678@saiqi.app');
  });

  test('affichage lisible', () {
    expect(PhoneUtils.pretty('+22236123456'), '+222 36 12 34 56');
    expect(PhoneUtils.pretty('36123456'), '+222 36 12 34 56');
    expect(PhoneUtils.digits('+222 36 12 34 56'), '22236123456');
  });
}
