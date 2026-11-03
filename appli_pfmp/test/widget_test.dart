import 'package:appli_pfmp/application/authentification.dart';
import 'package:appli_pfmp/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('application starts on login and validates credentials locally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    // Exercise the real providers, localization, theme and initial route.
    app.main();
    await tester.pumpAndSettle();

    expect(find.byType(PageAuth), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(
      find.image(const AssetImage('images/logo-noir.png')),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, "Nom d'utilisateur"),
      findsOneWidget,
    );

    final passwordField = find.widgetWithText(TextFormField, 'Mot de passe');
    final passwordInput = find.descendant(
      of: passwordField,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);
    await tester.enterText(passwordField, 'smoke-password');
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);
    expect(find.text('smoke-password'), findsOneWidget);

    // An empty username is rejected by the form before any login request.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Veuillez entrer une adresse mail'), findsOneWidget);
    expect(find.byType(PageAuth), findsOneWidget);
    expect(find.byType(app.PfmpManager), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
