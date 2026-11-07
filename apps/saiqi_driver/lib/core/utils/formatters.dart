import 'package:intl/intl.dart';

/// Formats d'affichage. Chiffres latins dans les deux langues (usage courant en Mauritanie) :
/// l'arabe utilise la locale `ar_MA` (chiffres latins) pour les dates.
class Fmt {
  const Fmt._();

  static String _dateLocale(String lang) => lang == 'fr' ? 'fr' : 'ar_MA';

  /// 1500 -> `1 500` (fr) / `1,500` (ar). Montants en MRU entiers.
  static String number(int value, String lang) {
    final f = NumberFormat.decimalPattern(lang == 'fr' ? 'fr' : 'en');
    return f.format(value).replaceAll(' ', ' ').replaceAll(' ', ' ');
  }

  /// `1 500 MRU` / `1,500 أوقية` (suffixe fourni par l10n).
  static String mru(int value, String lang) => '${number(value, lang)} ${lang == 'fr' ? 'MRU' : 'أوقية'}';

  static String signedMru(int value, String lang) {
    final sign = value > 0 ? '+' : (value < 0 ? '−' : '');
    return '$sign${mru(value.abs(), lang)}';
  }

  static String date(DateTime d, String lang) => DateFormat.yMMMd(_dateLocale(lang)).format(d);

  static String time(DateTime d, String lang) => DateFormat.Hm(_dateLocale(lang)).format(d);

  static String dateTime(DateTime d, String lang) =>
      '${DateFormat.yMMMd(_dateLocale(lang)).format(d)} ${DateFormat.Hm(_dateLocale(lang)).format(d)}';

  static String dayMonth(DateTime d, String lang) => DateFormat.MMMEd(_dateLocale(lang)).format(d);

  /// `mm:ss` pour les comptes à rebours.
  static String countdown(Duration d) {
    final s = d.inSeconds < 0 ? 0 : d.inSeconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  static String rating(double value) => value.toStringAsFixed(1);

  static String percent(double rate) {
    final p = rate * 100;
    return '${p == p.roundToDouble() ? p.round() : p.toStringAsFixed(1)}%';
  }

  static bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
