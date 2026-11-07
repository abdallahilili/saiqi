import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core.dart';

/// Dossier du chauffeur connecté, en temps réel (le statut de validation change sans rafraîchir).
final myDriverProvider = StreamProvider<Driver?>((ref) {
  final uid = ref.watch(authUserIdProvider).value;
  if (uid == null) return Stream.value(null);
  return ref.watch(driverRepositoryProvider).watchMyDriver();
});

final driverIdProvider = Provider<String?>((ref) => ref.watch(myDriverProvider).value?.id);

// ---- dossier -----------------------------------------------------------------
final vehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final id = ref.watch(driverIdProvider);
  if (id == null) return null;
  return ref.watch(driverRepositoryProvider).myVehicle(id);
});

final driverServicesProvider = FutureProvider<List<DriverService>>((ref) async {
  final id = ref.watch(driverIdProvider);
  if (id == null) return const [];
  return ref.watch(driverRepositoryProvider).myServices(id);
});

final availabilityProvider = FutureProvider<List<DriverAvailability>>((ref) async {
  final id = ref.watch(driverIdProvider);
  if (id == null) return const [];
  return ref.watch(driverRepositoryProvider).myAvailability(id);
});

final documentsProvider = StreamProvider<List<DriverDocument>>((ref) {
  final id = ref.watch(driverIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(driverRepositoryProvider).watchDocuments(id);
});

// ---- activité ------------------------------------------------------------------
final walletProvider = StreamProvider<Wallet?>((ref) {
  final id = ref.watch(driverIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(walletRepositoryProvider).watchWallet(id);
});

final incomingRequestsProvider = StreamProvider<List<IncomingRequest>>((ref) {
  final id = ref.watch(driverIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(bookingRepositoryProvider).watchIncoming(id);
});

final driverBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final id = ref.watch(driverIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(bookingRepositoryProvider).watchDriverBookings(id);
});

final tripProvider = StreamProvider.autoDispose.family<Booking, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).watchBooking(id),
);

final clientContactProvider = FutureProvider.autoDispose.family<BookingContact, String>(
  (ref, bookingId) => ref.watch(bookingRepositoryProvider).contact(bookingId),
);

// ---- portefeuille ------------------------------------------------------------------
/// Se recharge à chaque changement de solde (Realtime).
final walletTxProvider = FutureProvider.autoDispose<List<WalletTx>>((ref) {
  ref.watch(walletProvider);
  return ref.watch(walletRepositoryProvider).transactions();
});

final topupsProvider = StreamProvider.autoDispose<List<TopupRequest>>((ref) {
  final id = ref.watch(driverIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(walletRepositoryProvider).watchTopups(id);
});

// ---- profil ------------------------------------------------------------------------
final statsProvider = FutureProvider.autoDispose<DriverStats>((ref) {
  ref.watch(driverBookingsProvider);
  return ref.watch(driverRepositoryProvider).stats();
});

final reviewsProvider = FutureProvider.autoDispose<List<Review>>((ref) async {
  final id = ref.watch(driverIdProvider);
  if (id == null) return const [];
  return ref.watch(driverRepositoryProvider).myReviews(id);
});

/// Éléments manquants pour pouvoir soumettre le dossier (clés = étapes).
class ApplicationProgress {
  const ApplicationProgress({
    required this.personal,
    required this.documents,
    required this.vehicle,
    required this.services,
    required this.availability,
  });

  final bool personal;
  final bool documents;
  final bool vehicle;
  final bool services;
  final bool availability;

  /// La disponibilité horaire n'est pas exigée pour soumettre (seulement recommandée).
  bool get canSubmit => personal && documents && vehicle && services;
}

final applicationProgressProvider = Provider<AsyncValue<ApplicationProgress>>((ref) {
  final profile = ref.watch(profileProvider);
  final driver = ref.watch(myDriverProvider);
  final vehicle = ref.watch(vehicleProvider);
  final services = ref.watch(driverServicesProvider);
  final docs = ref.watch(documentsProvider);
  final availability = ref.watch(availabilityProvider);

  final all = [profile, driver, vehicle, services, docs, availability];
  for (final a in all) {
    if (a.hasError) return AsyncError(a.error!, a.stackTrace ?? StackTrace.empty);
  }
  if (all.any((a) => !a.hasValue)) return const AsyncLoading();

  final docList = docs.requireValue;
  final hasAllDocs = requiredDocumentTypes.every(
    (t) => docList.any((d) => d.type == t && d.status != DocumentStatus.rejected),
  );
  return AsyncData(ApplicationProgress(
    personal: (profile.requireValue?.fullName?.trim().isNotEmpty ?? false) && driver.requireValue?.cityId != null,
    documents: hasAllDocs,
    vehicle: vehicle.requireValue != null,
    services: services.requireValue.any((s) => s.isActive),
    availability: availability.requireValue.isNotEmpty,
  ));
});
