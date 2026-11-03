import 'package:appli_pfmp/application/formulaire_nouvelle_pfmp.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pending creation is visible and keeps the form mounted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bloc = PfmpBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: FormPfmp(
              lEcran: 1200,
              hEcran: 1000,
              etudiant: Utilisateur(
                id: 1,
                nom: 'Fixture',
                prenom: 'Test',
                role: 'Etudiant',
              ),
              onClose: () {},
            ),
          ),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Enregistrer'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(FormPfmp),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    bloc.emit(const PfmpPostLoadingState());
    await tester.pump();
    expect(find.byType(Form), findsOneWidget);
    expect(find.text('Enregistrement en cours…'), findsOneWidget);
  });
}
