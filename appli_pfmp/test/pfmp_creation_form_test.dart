import 'dart:convert';

import 'package:appli_pfmp/application/formulaire_nouvelle_pfmp.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_form.dart';
import 'package:appli_pfmp/custom/custom_widgets/entree_horaire.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Capture the real form boundary without invoking any HTTP event handler.
class RecordingPfmpBloc extends PfmpBloc {
  final submissions = <Map<String, dynamic>>[];

  @override
  void add(PfmpEvent event) {
    if (event is PfmpPostEvent) {
      submissions.add(Map<String, dynamic>.from(event.informations));
      return;
    }
    throw StateError('Unexpected event in isolated form test: $event');
  }
}

Finder get _formScroll => find
    .descendant(of: find.byType(FormPfmp), matching: find.byType(Scrollable))
    .first;

Finder _input(String hint) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is EntreeForm && widget.hint == hint,
  ),
  matching: find.byType(TextFormField),
);

Future<RecordingPfmpBloc> _mountForm(WidgetTester tester) async {
  tester.view.resetPhysicalSize();
  tester.view.physicalSize = const Size(1200, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final bloc = RecordingPfmpBloc();
  addTearDown(bloc.close);
  await tester.pumpWidget(
    BlocProvider<PfmpBloc>.value(
      value: bloc,
      child: MaterialApp(
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: FormPfmp(
            lEcran: 1200,
            hEcran: 1000,
            etudiant: Utilisateur(
              id: 1,
              nom: 'Test',
              prenom: 'Fixture',
              role: 'Etudiant',
            ),
            onClose: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return bloc;
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    tester.state<ScrollableState>(_formScroll).position.jumpTo(0);
    await tester.pump();
  }
  await tester.scrollUntilVisible(finder, 150, scrollable: _formScroll);
  await tester.pumpAndSettle();
}

Future<void> _fillForm(
  WidgetTester tester, {
  String website = 'https://example.test/stages',
}) async {
  final inputs = {
    'Ex : Boutique Mode Aubusson': 'Entreprise test',
    'Ex : Mode': 'Services',
    '123 456 789': '12345678901234',
    'Numero, rue, code postal, ville': '1 rue de test',
    'https://...': website,
    'Ex : Martin': 'Prenom test',
    'Ex : Dupont': 'Nom test',
    'Ex : Responsable': 'Responsable',
    'Ex : martin.dupont@entreprise.fr': 'supervisor@example.test',
  };
  // Populate both company and supervisor telephone fields while scrolling
  // through the actual form. No production state is accessed or replaced.
  for (final hint in inputs.keys) {
    final field = _input(hint);
    await _reveal(tester, field);
    await tester.enterText(field, inputs[hint]!);
  }
  final scroll = tester.state<ScrollableState>(_formScroll);
  scroll.position.jumpTo(0);
  await tester.pump();
  final telephoneFields = find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is EntreeForm && widget.hint == '01 23 45 67 89',
    ),
    matching: find.byType(TextFormField),
  );
  // Fields kept alive after editing retain their controllers off screen.
  for (var index = 0; index < 2; index++) {
    final hint = index == 0 ? 'TELEPHONE *' : 'TELEPHONE';
    final field = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is EntreeForm && widget.txt == hint,
      ),
      matching: find.byType(TextFormField),
    );
    await _reveal(tester, field);
    await tester.enterText(field, '0100000000');
  }
  expect(telephoneFields.evaluate().isNotEmpty, isTrue);
  await _reveal(tester, find.text('Lun'));
  await tester.tap(find.text('Lun'));
  await tester.pumpAndSettle();
  for (final slot in {'08:00': '08:00', '12:00': '12:00'}.entries) {
    final field = find.descendant(
      of: find.byWidgetPredicate(
        (widget) => widget is EntreeHoraire && widget.hint == slot.key,
      ),
      matching: find.byType(TextFormField),
    );
    await _reveal(tester, field);
    await tester.enterText(field, slot.value);
  }
}

Future<void> _submit(WidgetTester tester) async {
  await _reveal(tester, find.text('Enregistrer'));
  await tester.tap(find.text('Enregistrer'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _selectDate(WidgetTester tester, String key, String date) async {
  final field = find.byKey(ValueKey(key));
  await _reveal(tester, field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  final dialog = find.byType(DatePickerDialog);
  expect(dialog, findsOneWidget);
  final input = find.descendant(
    of: dialog,
    matching: find.byType(TextFormField),
  );
  await tester.enterText(input, date);
  await tester.tap(find.widgetWithText(TextButton, 'Confirmer'));
  await tester.pumpAndSettle();
  expect(dialog, findsNothing);
}

void main() {
  testWidgets('control: form renders and rejects an empty required company', (
    tester,
  ) async {
    final bloc = await _mountForm(tester);
    final field = _input('Ex : Boutique Mode Aubusson');
    final state = tester.state<FormFieldState<String>>(field);
    expect(state.validate(), isFalse);
    expect(state.errorText, isNotEmpty);
    expect(bloc.submissions, isEmpty);
  });

  testWidgets('submitted payload includes the entered siteWeb value', (
    tester,
  ) async {
    final bloc = await _mountForm(tester);
    await _fillForm(tester);
    await _selectDate(tester, 'pfmp-start-date', '10/01/2027');
    await _selectDate(tester, 'pfmp-end-date', '20/01/2027');
    await _submit(tester);
    expect(bloc.submissions, hasLength(1));
    expect(
      bloc.submissions.single['siteWeb'],
      'https://example.test/stages',
      reason: 'The website entered in the form must reach PfmpPostEvent.',
    );
  });

  for (final value in ['', '   ']) {
    testWidgets('website validator rejects ${jsonEncode(value)}', (
      tester,
    ) async {
      await _mountForm(tester);
      final field = _input('https://...');
      await _reveal(tester, field);
      await tester.enterText(field, value);
      final state = tester.state<FormFieldState<String>>(field);
      expect(
        state.validate(),
        isFalse,
        reason: 'The API requires a nonblank website; validate it locally.',
      );
      expect(state.errorText, isNotEmpty);
    });
  }

  testWidgets(
    'no dates selected blocks submission instead of sending defaults',
    (tester) async {
      final bloc = await _mountForm(tester);
      await _fillForm(tester);
      await _submit(tester);
      expect(
        bloc.submissions,
        isEmpty,
        reason:
            'Missing selected dates must not dispatch a request. Captured: '
            '${jsonEncode(bloc.submissions)}',
      );
    },
  );

  testWidgets('period exposes start and end date selection controls', (
    tester,
  ) async {
    await _mountForm(tester);
    await _reveal(tester, find.text('PERIODE'));
    expect(
      find.textContaining(RegExp(r'd[ée]but', caseSensitive: false)),
      findsWidgets,
      reason: 'The period must expose an identifiable start-date control.',
    );
    expect(
      find.textContaining(RegExp(r'\bfin\b', caseSensitive: false)),
      findsWidgets,
      reason: 'The period must expose an identifiable end-date control.',
    );
  });

  testWidgets('selected dates and trimmed website reach the payload', (
    tester,
  ) async {
    final bloc = await _mountForm(tester);
    await _fillForm(tester);
    final website = _input('https://...');
    await _reveal(tester, website);
    await tester.enterText(website, '  https://example.test/stages  ');
    await _selectDate(tester, 'pfmp-start-date', '03/03/2027');
    await _selectDate(tester, 'pfmp-end-date', '17/03/2027');
    await _submit(tester);
    expect(bloc.submissions, hasLength(1));
    expect(bloc.submissions.single['dateDebut'], '2027-03-03');
    expect(bloc.submissions.single['dateFin'], '2027-03-17');
    expect(bloc.submissions.single['siteWeb'], 'https://example.test/stages');
  });

  testWidgets('moving the start beyond the end blocks submission', (
    tester,
  ) async {
    final bloc = await _mountForm(tester);
    await _fillForm(tester);
    await _selectDate(tester, 'pfmp-end-date', '05/01/2027');
    await _selectDate(tester, 'pfmp-start-date', '10/01/2027');
    await _submit(tester);
    expect(bloc.submissions, isEmpty);
    expect(find.textContaining('fin doit'), findsWidgets);
  });

  testWidgets('a same-day period remains valid', (tester) async {
    final bloc = await _mountForm(tester);
    await _fillForm(tester);
    await _selectDate(tester, 'pfmp-start-date', '10/01/2027');
    await _selectDate(tester, 'pfmp-end-date', '10/01/2027');
    await _submit(tester);
    expect(bloc.submissions, hasLength(1));
    expect(bloc.submissions.single['dateDebut'], '2027-01-10');
    expect(bloc.submissions.single['dateFin'], '2027-01-10');
  });

  testWidgets('cancelling a date picker preserves its selection', (
    tester,
  ) async {
    final bloc = await _mountForm(tester);
    await _fillForm(tester);
    await _selectDate(tester, 'pfmp-start-date', '10/01/2027');
    await _selectDate(tester, 'pfmp-end-date', '20/01/2027');
    final start = find.byKey(const ValueKey('pfmp-start-date'));
    await _reveal(tester, start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.widgetWithText(TextButton, 'Annuler'),
      ),
    );
    await tester.pumpAndSettle();
    await _submit(tester);
    expect(bloc.submissions, hasLength(1));
    expect(bloc.submissions.single['dateDebut'], '2027-01-10');
    expect(bloc.submissions.single['dateFin'], '2027-01-20');
  });

  testWidgets('an empty website blocks submission with otherwise valid dates', (
    tester,
  ) async {
    final bloc = await _mountForm(tester);
    await _fillForm(tester, website: '');
    await _selectDate(tester, 'pfmp-start-date', '10/01/2027');
    await _selectDate(tester, 'pfmp-end-date', '20/01/2027');
    await _submit(tester);
    expect(bloc.submissions, isEmpty);
    expect(find.textContaining('site web'), findsWidgets);
  });
}
