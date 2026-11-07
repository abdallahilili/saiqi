import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saiqi_driver/core/core.dart';

import '../helpers.dart';

void main() {
  testWidgets('connexion : champs obligatoires et numéro invalide', (tester) async {
    await pumpApp(tester, SizedBox(height: 800, child: LoginScreen(onRegister: () {})));
    await tester.pump();

    expect(find.text('Se connecter'), findsWidgets);
    expect(find.text('+222'), findsNothing); // le préfixe est dans le champ (prefixText)

    // soumission à vide
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pump();
    expect(find.text('Ce champ est obligatoire'), findsWidgets);

    // numéro trop court
    await tester.enterText(find.byType(TextFormField).first, '1234');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pump();
    expect(find.text('Saisissez un numéro mauritanien valide de 8 chiffres'), findsOneWidget);
  });

  testWidgets('inscription : confirmation du mot de passe et 8 caractères minimum', (tester) async {
    await pumpApp(tester, SizedBox(height: 900, child: RegisterScreen(onLogin: () {})));
    await tester.pump();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(3)); // téléphone, mot de passe, confirmation

    await tester.enterText(fields.at(0), '36123456');
    await tester.enterText(fields.at(1), 'court');
    await tester.enterText(fields.at(2), 'autre');
    await tester.tap(find.widgetWithText(FilledButton, 'Créer un compte'));
    await tester.pump();

    expect(find.text('Le mot de passe doit contenir au moins 8 caractères'), findsOneWidget);
    expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);
  });

  testWidgets('connexion sans lien vers l\'inscription (app Admin)', (tester) async {
    await pumpApp(tester, const SizedBox(height: 800, child: LoginScreen()));
    await tester.pump();
    expect(find.text('Créer un compte'), findsNothing);
    expect(find.text('Pas encore de compte ?'), findsNothing);
  });

  testWidgets('arabe : titre et champs en RTL', (tester) async {
    await pumpApp(tester, SizedBox(height: 800, child: LoginScreen(onRegister: () {})), lang: 'ar');
    await tester.pump();
    expect(find.text('مرحبًا بعودتك'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(LoginScreen))), TextDirection.rtl);
  });
}
