import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:saiqi_driver/app/providers.dart';
import 'package:saiqi_driver/core/core.dart';
import 'package:saiqi_driver/features/requests/presentation/request_actions.dart';

import '../helpers.dart';

IncomingRequest _request({int price = 1000, int commission = 150}) => IncomingRequest(
      offerId: 'o1',
      bookingId: 'b1',
      clientName: 'Mohamed Ould Ahmed',
      pickupText: 'Aéroport Oumtounsy',
      dropoffText: 'Tevragh Zeina',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      passengers: 2,
      price: price,
      commissionRate: 0.15,
      commissionAmount: commission,
      channel: BookingChannel.app,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 8)),
      serviceNameAr: 'سيارة أجرة',
      serviceNameFr: 'Taxi',
      cityNameAr: 'نواكشوط',
      cityNameFr: 'Nouakchott',
    );

Override _wallet(int balance) =>
    walletProvider.overrideWith((ref) => Stream.value(Wallet(id: 'w1', driverId: 'd1', balance: balance)));

void main() {
  testWidgets('solde suffisant : Accepter et Refuser sont proposés, commission affichée', (tester) async {
    await pumpApp(tester, IncomingRequestCard(request: _request()), overrides: [_wallet(500)]);
    await tester.pump();

    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('Accepter'), findsOneWidget);
    expect(find.text('Refuser'), findsOneWidget);
    expect(find.textContaining('150 MRU'), findsWidgets); // commission
    expect(find.text('Recharger mon portefeuille'), findsNothing);
  });

  testWidgets('solde insuffisant : acceptation bloquée, invitation à recharger', (tester) async {
    await pumpApp(tester, IncomingRequestCard(request: _request()), overrides: [_wallet(40)]);
    await tester.pump();

    expect(find.text('Accepter'), findsNothing);
    expect(find.text('Recharger mon portefeuille'), findsOneWidget);
    expect(find.textContaining('ne couvre pas la commission'), findsOneWidget);
    expect(find.text('Refuser'), findsOneWidget);
  });

  testWidgets('interface arabe : sens RTL et libellés arabes', (tester) async {
    await pumpApp(tester, IncomingRequestCard(request: _request()), overrides: [_wallet(500)], lang: 'ar');
    await tester.pump();

    expect(find.text('سيارة أجرة'), findsOneWidget);
    expect(find.text('قبول الطلب'), findsOneWidget);
    final context = tester.element(find.byType(IncomingRequestCard));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
