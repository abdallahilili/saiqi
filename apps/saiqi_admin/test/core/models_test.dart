import 'package:flutter_test/flutter_test.dart';

import 'package:saiqi_admin/core/core.dart';

void main() {
  test('énumérations <-> valeurs Postgres', () {
    expect(BookingStatus.enRoute.db, 'en_route');
    expect(BookingStatus.inProgress.db, 'in_progress');
    expect(DocumentType.vehicleRegistration.db, 'vehicle_registration');
    expect(PriceUnit.perTrip.db, 'per_trip');
    expect(AdminRole.superAdmin.db, 'super_admin');
    expect(ComplaintStatus.inReview.db, 'in_review');
    expect(enumFromDb(BookingStatus.values, 'in_progress', BookingStatus.pending), BookingStatus.inProgress);
    expect(enumFromDb(BookingStatus.values, 'inconnu', BookingStatus.pending), BookingStatus.pending);
  });

  test('visibilité du contact selon le statut', () {
    expect(BookingStatus.pending.contactVisible, isFalse);
    expect(BookingStatus.cancelled.contactVisible, isFalse);
    expect(BookingStatus.accepted.contactVisible, isTrue);
    expect(BookingStatus.completed.contactVisible, isTrue);
    expect(BookingStatus.completed.isFinal, isTrue);
    expect(BookingStatus.enRoute.isActive, isTrue);
  });

  test('Profile.fromJson', () {
    final p = Profile.fromJson({
      'id': 'u1',
      'role': 'driver',
      'full_name': 'Sidi',
      'phone': '+22222000001',
      'language': 'fr',
      'status': 'suspended',
      'admin_role': null,
    });
    expect(p.role, UserRole.driver);
    expect(p.status, AccountStatus.suspended);
    expect(p.displayName, 'Sidi');
    expect(Profile.fromJson({'id': 'x', 'role': 'client', 'phone': '+22236000001'}).displayName, '+22236000001');
  });

  test('Booking.fromJson avec relations imbriquées', () {
    final b = Booking.fromJson({
      'id': 'b1',
      'client_name': 'Mohamed',
      'client_phone': '+22236000001',
      'service_type_id': 's1',
      'city_id': 'c1',
      'pickup_text': 'Aéroport',
      'scheduled_at': '2026-03-05T10:00:00Z',
      'passengers': 2,
      'price': 400,
      'status': 'en_route',
      'channel': 'whatsapp',
      'created_by_type': 'admin',
      'created_at': '2026-03-05T09:00:00Z',
      'service_types': {'name_ar': 'تاكسي', 'name_fr': 'Taxi'},
      'cities': [
        {'name_ar': 'نواكشوط', 'name_fr': 'Nouakchott'},
      ],
    });
    expect(b.status, BookingStatus.enRoute);
    expect(b.channel, BookingChannel.whatsapp);
    expect(b.createdByAdmin, isTrue);
    expect(b.serviceName('fr'), 'Taxi');
    expect(b.cityName('ar'), 'نواكشوط');
    expect(b.price, 400);
  });

  test('IncomingRequest : commission annoncée, aucun téléphone', () {
    final r = IncomingRequest.fromJson({
      'offer_id': 'o1',
      'booking_id': 'b1',
      'client_name': 'Fatimetou',
      'pickup_text': 'Ksar',
      'scheduled_at': '2026-03-05T10:00:00Z',
      'passengers': 1,
      'price': 1000,
      'commission_rate': 0.15,
      'commission_amount': 150,
      'channel': 'app',
      'created_at': '2026-03-05T09:00:00Z',
    });
    expect(r.commissionAmount, 150);
    expect(r.commissionRate, 0.15);
  });

  test('Wallet / WalletTx : montants signés', () {
    final tx = WalletTx.fromJson({
      'id': 't1',
      'type': 'commission',
      'amount': -150,
      'balance_after': 150,
      'created_at': '2026-03-05T09:00:00Z',
    });
    expect(tx.type, WalletTxType.commission);
    expect(tx.amount, -150);
    expect(Wallet.fromJson({'id': 'w', 'driver_id': 'd', 'balance': 300}).balance, 300);
  });

  test('AppSettings typés et valeurs par défaut', () {
    const s = AppSettings({
      'default_commission_rate': 0.1,
      'response_timeout_minutes': 10,
      'topup_methods': [
        {'id': 'bankily', 'name_ar': 'بنكيلي', 'name_fr': 'Bankily', 'account': '36000000'},
      ],
    });
    expect(s.defaultCommissionRate, 0.1);
    expect(s.responseTimeoutMinutes, 10);
    expect(s.lowBalanceThreshold, 100);
    expect(s.topupMethods.single.name('fr'), 'Bankily');
    expect(AppSettings.empty.minTopupAmount, 100);
  });

  test('PublicDriver depuis search_drivers (une photo)', () {
    final d = PublicDriver.fromJson({
      'driver_id': 'd1',
      'full_name': 'Sidi',
      'rating_avg': 4.5,
      'rating_count': 12,
      'completed_count': 30,
      'is_available': true,
      'vehicle_brand': 'Toyota',
      'vehicle_model': 'Corolla',
      'vehicle_photo': 'u/v/1.jpg',
      'price': 150,
      'price_unit': 'per_trip',
    });
    expect(d.vehicleTitle, 'Toyota Corolla');
    expect(d.vehiclePhotos, ['u/v/1.jpg']);
    expect(d.priceUnit, PriceUnit.perTrip);
    expect(d.ratingAvg, 4.5);
  });
}
