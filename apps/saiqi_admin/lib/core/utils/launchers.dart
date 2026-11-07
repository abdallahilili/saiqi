import 'package:url_launcher/url_launcher.dart';

import 'phone.dart';

/// Appel téléphonique et WhatsApp (nécessitent les déclarations natives `queries` / `LSApplicationQueriesSchemes`).
class Launchers {
  const Launchers._();

  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: PhoneUtils.normalize(phone) ?? phone);
    return launchUrl(uri);
  }

  static Future<bool> whatsapp(String phone, {String? message}) async {
    final digits = PhoneUtils.digits(PhoneUtils.normalize(phone) ?? phone);
    final uri = Uri.https('wa.me', '/$digits', {if (message != null && message.isNotEmpty) 'text': message});
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openUrl(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
