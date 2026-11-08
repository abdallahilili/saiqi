import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saiqi_admin/core/core.dart';

void main() {
  testWidgets('« Continuer » confirme la langue même si l\'arabe par défaut est conservé', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light(),
            home: LanguageWelcomeScreen(onContinue: () {}),
          ),
        ),
      ),
    );
    await tester.pump();

    final container = ProviderScope.containerOf(tester.element(find.byType(LanguageWelcomeScreen)));
    expect(container.read(localeProvider).languageCode, 'ar', reason: 'arabe par défaut');
    expect(container.read(languageChosenProvider), isFalse);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(container.read(languageChosenProvider), isTrue);
    expect(prefs.getBool('pref.language_chosen'), isTrue);
    expect(container.read(localeProvider).languageCode, 'ar');
  });
}
