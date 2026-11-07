import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:saiqi_client/app/providers.dart';
import 'package:saiqi_client/core/core.dart';
import 'package:saiqi_client/features/booking/presentation/booking_detail_screen.dart';
import 'package:saiqi_client/features/drivers/presentation/drivers_screen.dart';
import 'package:saiqi_client/features/home/presentation/home_screen.dart';

import '../helpers.dart';

class _FakeProfile extends ProfileNotifier {
  @override
  Future<Profile?> build() async => const Profile(
        id: 'c1',
        role: UserRole.client,
        phone: '+22236000001',
        language: 'fr',
        status: AccountStatus.active,
        fullName: 'Mohamed Ould Ahmed',
      );
}

class _FakeFavorites extends FavoritesNotifier {
  @override
  Future<Set<String>> build() async => {'d1'};
}

const _cities = [
  City(id: 'nkc', nameAr: 'نواكشوط', nameFr: 'Nouakchott'),
  City(id: 'ndb', nameAr: 'نواذيبو', nameFr: 'Nouadhibou'),
];
const _services = [
  ServiceType(id: 'taxi', nameAr: 'سيارة أجرة', nameFr: 'Taxi', icon: 'local_taxi'),
  ServiceType(id: '4x4', nameAr: 'دفع رباعي', nameFr: '4×4', icon: 'terrain'),
];

List<Override> _base() => [
      profileProvider.overrideWith(_FakeProfile.new),
      favoritesProvider.overrideWith(_FakeFavorites.new),
      citiesProvider.overrideWith((ref) async => _cities),
      serviceTypesProvider.overrideWith((ref) async => _services),
      unreadNotificationsProvider.overrideWith((ref) => Stream.value(2)),
    ];

Booking _booking(BookingStatus status) => Booking(
      id: 'b1',
      clientName: 'Mohamed Ould Ahmed',
      serviceTypeId: 'taxi',
      cityId: 'nkc',
      pickupText: 'Aéroport',
      dropoffText: 'Ksar',
      scheduledAt: DateTime.now().add(const Duration(hours: 3)),
      passengers: 2,
      price: 400,
      status: status,
      channel: BookingChannel.app,
      createdByType: 'client',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 9)),
      driverId: 'd1',
      serviceNameFr: 'Taxi',
      serviceNameAr: 'سيارة أجرة',
      cityNameFr: 'Nouakchott',
      cityNameAr: 'نواكشوط',
    );

const _driverInfo = BookingDriverInfo(
  driverId: 'd1',
  fullName: 'Sidi Ould Mohamed',
  ratingAvg: 4.5,
  ratingCount: 12,
  vehicleBrand: 'Toyota',
  vehicleModel: 'Corolla',
  vehiclePlate: '1204 AB 00',
);

List<Override> _bookingOverrides(BookingStatus status) => [
      ..._base(),
      bookingProvider.overrideWith((ref, id) => Stream.value(_booking(status))),
      bookingDriverProvider.overrideWith((ref, id) async => _driverInfo),
      driverContactProvider.overrideWith((ref, id) async => const BookingContact(fullName: 'Sidi', phone: '+22222000001')),
      reviewForBookingProvider.overrideWith((ref, id) async => null),
    ];

void main() {
  testWidgets('accueil : villes et types de service du catalogue', (tester) async {
    await pumpScreen(tester, const HomeScreen(), overrides: _base());
    await tester.pumpAndSettle();

    expect(find.text('Trouvez votre chauffeur'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('4×4'), findsOneWidget);
    expect(find.text('Voir les chauffeurs'), findsOneWidget);
  });

  testWidgets('liste des chauffeurs : carte, note, prix, favori', (tester) async {
    await pumpScreen(
      tester,
      const DriversScreen(cityId: 'nkc', serviceTypeId: 'taxi'),
      overrides: [
        ..._base(),
        driversSearchProvider.overrideWith(
          (ref, q) async => const [
            PublicDriver(
              driverId: 'd1',
              fullName: 'Sidi Ould Mohamed',
              ratingAvg: 4.5,
              ratingCount: 12,
              completedCount: 30,
              isAvailable: true,
              vehicleBrand: 'Toyota',
              vehicleModel: 'Corolla',
              seats: 4,
              price: 150,
              priceUnit: PriceUnit.perTrip,
              cityId: 'nkc',
            ),
          ],
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Sidi Ould Mohamed'), findsOneWidget);
    expect(find.textContaining('150 MRU'), findsOneWidget);
    expect(find.text('Disponible'), findsWidgets);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget); // d1 est en favori
    expect(find.text('1 chauffeur(s)'), findsOneWidget);
  });

  testWidgets('suivi : en attente -> pas de téléphone, annulation possible', (tester) async {
    await pumpScreen(tester, const BookingDetailScreen(bookingId: 'b1'), overrides: _bookingOverrides(BookingStatus.pending));
    // barre de progression + compte à rebours animés en continu : pas de pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('En attente'), findsWidgets);
    expect(find.textContaining('Nous vous prévenons dès sa réponse'), findsOneWidget);
    expect(find.text('Le numéro du chauffeur apparaît après acceptation.'), findsOneWidget);
    expect(find.text('Appeler'), findsNothing);
    expect(find.text('Annuler la réservation'), findsOneWidget);
  });

  testWidgets('suivi : acceptée -> contact (appel + WhatsApp) visible', (tester) async {
    await pumpScreen(tester, const BookingDetailScreen(bookingId: 'b1'), overrides: _bookingOverrides(BookingStatus.accepted));
    await tester.pumpAndSettle();

    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.textContaining('+222 22 00 00 01'), findsOneWidget);
    expect(find.text('Annuler la réservation'), findsOneWidget);
  });

  testWidgets('suivi : en route -> annulation interdite', (tester) async {
    await pumpScreen(tester, const BookingDetailScreen(bookingId: 'b1'), overrides: _bookingOverrides(BookingStatus.enRoute));
    await tester.pumpAndSettle();

    expect(find.text('Annuler la réservation'), findsNothing);
    expect(find.textContaining("n'est plus possible une fois le chauffeur en route"), findsOneWidget);
  });

  testWidgets("suivi : terminée -> formulaire d'évaluation", (tester) async {
    await pumpScreen(tester, const BookingDetailScreen(bookingId: 'b1'), overrides: _bookingOverrides(BookingStatus.completed));
    await tester.pumpAndSettle();

    expect(find.text('Évaluer le chauffeur'), findsOneWidget);
    expect(find.text("Envoyer l'avis"), findsOneWidget);
  });

  testWidgets('arabe : accueil en RTL', (tester) async {
    await pumpScreen(tester, const HomeScreen(), overrides: _base(), lang: 'ar');
    await tester.pumpAndSettle();
    expect(find.text('ابحث عن سائقك'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(HomeScreen))), TextDirection.rtl);
  });
}
