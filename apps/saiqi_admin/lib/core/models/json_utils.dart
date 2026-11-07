import 'enums.dart';

int asInt(Object? v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.round();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double asDouble(Object? v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

DateTime? asDate(Object? v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}

DateTime asDateOr(Object? v, DateTime fallback) => asDate(v) ?? fallback;

List<String> asStringList(Object? v) =>
    v is List ? v.map((e) => e.toString()).toList() : const <String>[];

Json asJson(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Json> asJsonList(Object? v) =>
    v is List ? v.map((e) => asJson(e)).toList() : const <Json>[];

/// PostgREST renvoie les relations 1-1 comme objet et 1-n comme liste.
Json? firstJson(Object? v) {
  if (v is List) return v.isEmpty ? null : asJson(v.first);
  if (v is Map) return asJson(v);
  return null;
}
