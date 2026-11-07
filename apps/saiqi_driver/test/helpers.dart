import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saiqi_driver/core/core.dart';

/// Variante pour un écran complet (Scaffold) : pas de défilement englobant.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  String lang = 'fr',
}) => _pump(tester, screen, overrides, lang, wrap: false);

/// Monte un widget avec localisation (ar/fr), thème SAIQI et surcharges Riverpod — sans Supabase.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  String lang = 'fr',
}) => _pump(tester, child, overrides, lang, wrap: true);

Future<void> _pump(WidgetTester tester, Widget child, List<Override> overrides, String lang, {required bool wrap}) async {
  // grand écran logique : tous les widgets des formulaires restent visibles et cliquables
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({'pref.locale': lang, 'pref.language_chosen': true});
  final prefs = await SharedPreferences.getInstance();
  await initializeDateFormatting();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        expectedRoleProvider.overrideWithValue(UserRole.driver),
        ...overrides,
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          locale: ref.watch(localeProvider),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          home: wrap ? Scaffold(body: SingleChildScrollView(child: child)) : child,
        ),
      ),
    ),
  );
  await tester.pump();
}
