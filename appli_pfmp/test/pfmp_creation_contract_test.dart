import 'dart:async';
import 'dart:convert';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/data/pfmp_api.dart';
import 'package:appli_pfmp/model/pfmp_creation_receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const receiptJson = <String, dynamic>{
  'idPfmp': 42,
  'idEtudiant': 7,
  'id_Planning': 11,
  'idAdministrateur': 3,
  'siret': '12345678901234',
  'dateDebut': '2027-01-04T00:00:00',
  'dateFin': '2027-01-08T00:00:00',
  'jourRestants': 0,
  'raisonSociale': '',
  'semaine': 0,
};
PfmpCreationReceipt receipt() => PfmpCreationReceipt.fromJson(receiptJson);
Future<void> turn() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'stale GET cannot overwrite confirmed save and reload failure',
    () async {
      final earlierLoad = Completer<List<Never>?>();
      var gets = 0;
      final bloc = PfmpBloc(
        load: (_, _) {
          gets++;
          return gets == 1 ? earlierLoad.future : Future.value(null);
        },
        create: (_) async => receipt(),
      );
      addTearDown(bloc.close);
      bloc.add(const PfmpInitializeEvent(7, null));
      await turn();
      bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
      await turn();
      await turn();
      expect(bloc.state, isA<PfmpReloadErrorState>());
      earlierLoad.complete([]);
      await turn();
      expect(bloc.state, isA<PfmpReloadErrorState>());
      expect(bloc.creationNeedsReload, isTrue);
    },
  );
  test('stale GET failure cannot replace pending submission', () async {
    final earlierLoad = Completer<List<Never>?>();
    final pendingPost = Completer<PfmpCreationReceipt>();
    var gets = 0;
    final bloc = PfmpBloc(
      load: (_, _) {
        gets++;
        return gets == 1 ? earlierLoad.future : Future.value([]);
      },
      create: (_) => pendingPost.future,
    );
    addTearDown(bloc.close);
    bloc.add(const PfmpInitializeEvent(7, null));
    await turn();
    bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
    await turn();
    earlierLoad.complete(null);
    await turn();
    final stateWhilePosting = bloc.state;
    pendingPost.complete(receipt());
    await turn();
    await turn();
    expect(stateWhilePosting, isA<PfmpPostLoadingState>());
    expect(bloc.state, isA<PfmpSuccessState>());
  });
  test('overlapping GET retries retain the latest successful result', () async {
    final earlierRetry = Completer<List<Never>?>();
    var gets = 0;
    final bloc = PfmpBloc(
      load: (_, _) {
        gets++;
        if (gets == 1) return Future.value(null);
        return gets == 2 ? earlierRetry.future : Future.value([]);
      },
      create: (_) async => receipt(),
    );
    addTearDown(bloc.close);
    bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
    await turn();
    await turn();
    expect(bloc.state, isA<PfmpReloadErrorState>());
    bloc.add(const PfmpInitializeEvent(7, null));
    await turn();
    bloc.add(const PfmpInitializeEvent(7, null));
    await turn();
    expect(bloc.state, isA<PfmpSuccessState>());
    earlierRetry.complete(null);
    await turn();
    expect(bloc.state, isA<PfmpSuccessState>());
  });
  test(
    'compact POST response preserves backend receipt fields without detail fields',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/pfmp/complete');
        expect(jsonDecode(request.body), {
          'idEtudiant': 7,
          'dateDebut': '2027-01-04',
        });
        return http.Response(jsonEncode(receiptJson), 200);
      });
      final result = await sendPfmp({
        'idEtudiant': 7,
        'dateDebut': '2027-01-04',
      }, client: client);
      expect(result.idPfmp, 42);
      expect(result.idEtudiant, 7);
      expect(result.idPlanning, 11);
      expect(result.idAdministrateur, 3);
      expect(result.siret, receiptJson['siret']);
      expect(result.dateDebut, receiptJson['dateDebut']);
      expect(result.dateFin, receiptJson['dateFin']);
    },
  );
  test('validation response preserves business error', () async {
    final client = MockClient(
      (_) async => http.Response('Planning invalide', 400),
    );
    await expectLater(
      sendPfmp({}, client: client),
      throwsA(
        isA<PfmpRequestException>()
            .having((e) => e.message, 'message', 'Planning invalide')
            .having((e) => e.outcomeUnknown, 'outcomeUnknown', false),
      ),
    );
  });
  test(
    'network failure is ambiguous and POST is never automatically retried',
    () async {
      var posts = 0;
      final client = MockClient((_) async {
        posts++;
        throw http.ClientException('offline');
      });
      await expectLater(
        sendPfmp({}, client: client),
        throwsA(
          isA<PfmpRequestException>().having(
            (e) => e.outcomeUnknown,
            'outcomeUnknown',
            true,
          ),
        ),
      );
      expect(posts, 1);
    },
  );
  test(
    'malformed successful receipt is ambiguous, not automatic POST retry',
    () async {
      var posts = 0;
      final client = MockClient((_) async {
        posts++;
        return http.Response('{}', 200);
      });
      await expectLater(
        sendPfmp({}, client: client),
        throwsA(
          isA<PfmpRequestException>().having(
            (e) => e.outcomeUnknown,
            'outcomeUnknown',
            true,
          ),
        ),
      );
      expect(posts, 1);
    },
  );
  test('GET server failure is not decoded as empty success', () async {
    expect(
      await requestPfmp(
        7,
        null,
        client: MockClient((_) async => http.Response('error', 500)),
      ),
      isNull,
    );
  });
  test(
    'pending submission suppresses duplicate events then reloads once',
    () async {
      var posts = 0;
      var gets = 0;
      final pending = Completer<PfmpCreationReceipt>();
      final bloc = PfmpBloc(
        create: (_) {
          posts++;
          return pending.future;
        },
        load: (_, _) async {
          gets++;
          return [];
        },
      );
      addTearDown(bloc.close);
      final states = <PfmpState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);
      bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
      await turn();
      expect(bloc.state, isA<PfmpPostLoadingState>());
      bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
      await turn();
      expect(posts, 1);
      pending.complete(receipt());
      await turn();
      await turn();
      expect(
        states.whereType<PfmpPostSuccessState>().single.nouvelleEntree.idPfmp,
        42,
      );
      expect(bloc.state, isA<PfmpSuccessState>());
      expect(gets, 1);
    },
  );
  test(
    'saved but GET failed offers GET-only retry and blocks repeated POST',
    () async {
      var posts = 0;
      var gets = 0;
      final bloc = PfmpBloc(
        create: (_) async {
          posts++;
          return receipt();
        },
        load: (_, _) async {
          gets++;
          return gets == 1 ? null : [];
        },
      );
      addTearDown(bloc.close);
      bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
      await turn();
      await turn();
      expect(bloc.state, isA<PfmpReloadErrorState>());
      bloc.add(const PfmpPostEvent({'idEtudiant': 7}));
      await turn();
      expect(posts, 1);
      bloc.add(const PfmpInitializeEvent(7, null));
      await turn();
      await turn();
      expect(bloc.state, isA<PfmpSuccessState>());
      expect(posts, 1);
      expect(gets, 2);
    },
  );
  test(
    'rejected submission is recoverable without a GET or implicit retry',
    () async {
      var calls = 0;
      final bloc = PfmpBloc(
        create: (_) async {
          calls++;
          throw const PfmpRequestException('Planning invalide');
        },
        load: (_, _) async => fail('No reload after rejection'),
      );
      addTearDown(bloc.close);
      bloc.add(const PfmpPostEvent({}));
      await turn();
      await turn();
      expect(
        bloc.state,
        isA<PfmpPostErrorState>().having(
          (s) => s.error,
          'error',
          'Planning invalide',
        ),
      );
      expect(bloc.submissionPending, false);
      expect(calls, 1);
    },
  );
}
