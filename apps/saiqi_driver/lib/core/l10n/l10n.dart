import 'package:flutter/material.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';
export 'l10n_labels.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Code langue courant (`ar` ou `fr`).
  String get lang => Localizations.localeOf(this).languageCode;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
