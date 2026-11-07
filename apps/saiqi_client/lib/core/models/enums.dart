/// Énumérations alignées sur les types Postgres (snake_case en base, camelCase en Dart).
library;

typedef Json = Map<String, dynamic>;

String _toSnake(String s) =>
    s.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

extension EnumDb on Enum {
  /// Valeur telle qu'enregistrée en base (ex. `enRoute` -> `en_route`).
  String get db => _toSnake(name);
}

T enumFromDb<T extends Enum>(List<T> values, Object? raw, T fallback) {
  final s = raw?.toString();
  for (final v in values) {
    if (v.db == s) return v;
  }
  return fallback;
}

enum UserRole { client, driver, admin }

enum AdminRole { superAdmin, validator, support }

enum AccountStatus { active, suspended, blocked }

enum DriverStatus { draft, pending, approved, rejected, suspended }

enum DocumentType { idCard, drivingLicense, vehicleRegistration, insurance, photo }

enum DocumentStatus { pending, approved, rejected }

enum BookingStatus {
  pending,
  accepted,
  enRoute,
  inProgress,
  completed,
  cancelled,
  rejected,
  expired;

  bool get isFinal => const {completed, cancelled, rejected, expired}.contains(this);
  bool get isActive => const {accepted, enRoute, inProgress}.contains(this);

  /// Le téléphone de l'autre partie est visible à partir de l'acceptation.
  bool get contactVisible => const {accepted, enRoute, inProgress, completed}.contains(this);
}

enum BookingChannel { app, phone, whatsapp, other }

enum WalletTxType { topup, commission, refund, adjustment }

enum TopupStatus { pending, approved, rejected }

enum ComplaintStatus { open, inReview, resolved, dismissed }

enum PriceUnit { perTrip, perHour, perDay }

const vehicleTypes = ['sedan', 'suv', '4x4', 'van', 'minibus', 'bus', 'pickup'];

/// Types de documents requis pour soumettre le dossier (l'assurance est facultative).
const requiredDocumentTypes = [
  DocumentType.idCard,
  DocumentType.drivingLicense,
  DocumentType.vehicleRegistration,
  DocumentType.photo,
];
