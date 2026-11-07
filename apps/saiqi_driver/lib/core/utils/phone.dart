/// Numéros mauritaniens : stockés `+222XXXXXXXX` (8 chiffres), identifiant de connexion.
class PhoneUtils {
  const PhoneUtils._();

  /// Normalise vers `+222XXXXXXXX`. Renvoie `null` si le numéro est invalide.
  static String? normalize(String? input) {
    if (input == null) return null;
    var d = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length == 13 && d.startsWith('00222')) {
      d = d.substring(5);
    } else if (d.length == 11 && d.startsWith('222')) {
      d = d.substring(3);
    }
    return RegExp(r'^[0-9]{8}$').hasMatch(d) ? '+222$d' : null;
  }

  static bool isValid(String? input) => normalize(input) != null;

  /// Email technique utilisé par Supabase Auth (jamais montré à l'utilisateur).
  static String technicalEmail(String normalizedPhone) =>
      '${normalizedPhone.replaceAll(RegExp(r'[^0-9]'), '')}@saiqi.app';

  /// `+22236123456` -> `+222 36 12 34 56`
  static String pretty(String? phone) {
    final n = normalize(phone);
    if (n == null) return phone ?? '';
    final d = n.substring(4);
    return '+222 ${d.substring(0, 2)} ${d.substring(2, 4)} ${d.substring(4, 6)} ${d.substring(6, 8)}';
  }

  /// Chiffres seuls avec indicatif, pour wa.me / tel:
  static String digits(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');
}
