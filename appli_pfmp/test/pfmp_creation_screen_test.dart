import 'dart:async';
import 'package:appli_pfmp/application/mes_pfmp.dart';
import 'package:appli_pfmp/application/formulaire_nouvelle_pfmp.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/data/pfmp_api.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'pfmp_creation_contract_test.dart' show receipt, receiptJson;

Future<void> mount(WidgetTester tester, PfmpBloc bloc) async {
  tester.view.physicalSize = const Size(1200, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(bloc.close);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: bloc,
          child: MesPfmp(
            utilisateur: Utilisateur(
              id: 7,
              nom: 'Fixture',
              prenom: 'Test',
              role: 'Etudiant',
            ),
            reportCountLoader: () async => 0,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('+ Nouvelle PFMP'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('creation stays disabled throughout saved-result GET retry', (
    tester,
  ) async {
    final existing = Pfmp.fromJson({
      ...receiptJson,
      'raisonSociale': 'Entreprise existante',
      'prenomMaitreStage': 'Test',
      'nomMaitreStage': 'Fixture',
      'fonctionMaitreStage': 'Tutor',
      'telephoneMaitreStage': '0100000000',
      'emailMaitreStage': 'fixture@example.test',
      'planningJours': [],
    });
    final retry = Completer<List<Pfmp?>?>();
    var gets = 0;
    final bloc = PfmpBloc(
      load: (_, _) {
        gets++;
        if (gets == 1) return Future.value([existing]);
        return gets == 2 ? Future.value(null) : retry.future;
      },
      create: (_) async => receipt(),
    );
    await mount(tester, bloc);
    bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réessayer le chargement'));
    await tester.pump();
    final button = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('+ Nouvelle PFMP'),
        matching: find.byType(TextButton),
      ),
    );
    retry.complete([existing]);
    await tester.pumpAndSettle();
    expect(button.onPressed, isNull);
    expect(find.byType(FormPfmp), findsNothing);
    final recoveredButton = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('+ Nouvelle PFMP'),
        matching: find.byType(TextButton),
      ),
    );
    expect(recoveredButton.onPressed, isNotNull);
  });
  testWidgets('pending and validation failure preserve entered form values', (
    tester,
  ) async {
    final pending = Completer();
    final bloc = PfmpBloc(
      load: (_, _) async => [],
      create: (_) async {
        await pending.future;
        throw const PfmpRequestException('Planning invalide');
      },
    );
    await mount(tester, bloc);
    final field = find
        .descendant(
          of: find.byType(FormPfmp),
          matching: find.byType(TextFormField),
        )
        .first;
    await tester.enterText(field, 'Entreprise conservée');
    bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
    await tester.pump();
    expect(find.byType(FormPfmp), findsOneWidget);
    expect(find.text('Entreprise conservée'), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Planning invalide'), findsOneWidget);
    expect(find.text('Entreprise conservée'), findsOneWidget);
  });
  testWidgets('saved reload failure closes form and retries only GET', (
    tester,
  ) async {
    var posts = 0;
    var gets = 0;
    final bloc = PfmpBloc(
      load: (_, _) async {
        gets++;
        return gets == 2 ? null : [];
      },
      create: (_) async {
        posts++;
        return receipt();
      },
    );
    await mount(tester, bloc);
    bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
    await tester.pumpAndSettle();
    expect(find.byType(FormPfmp), findsNothing);
    expect(
      find.text('PFMP enregistrée ; rechargement impossible.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Réessayer le chargement'));
    await tester.pumpAndSettle();
    expect(
      find.text('PFMP enregistrée ; rechargement impossible.'),
      findsNothing,
    );
    expect(find.text('Aucune PFMP enregistree'), findsOneWidget);
    expect(posts, 1);
    expect(gets, 3);
  });
  testWidgets('successful creation closes form and reloads list', (
    tester,
  ) async {
    var gets = 0;
    final bloc = PfmpBloc(
      load: (_, _) async {
        gets++;
        return [];
      },
      create: (_) async => receipt(),
    );
    await mount(tester, bloc);
    bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
    await tester.pumpAndSettle();
    expect(find.byType(FormPfmp), findsNothing);
    expect(find.text('PFMP enregistrée.'), findsOneWidget);
    expect(gets, 2);
  });
}
