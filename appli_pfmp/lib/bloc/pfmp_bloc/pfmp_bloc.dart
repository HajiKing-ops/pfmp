import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/data/pfmp_api.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/pfmp_creation_receipt.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef PfmpLoader = Future<List<Pfmp?>?> Function(int studentId, int? pfmpId);
typedef PfmpCreator = Future<PfmpCreationReceipt> Function(Map information);

class PfmpBloc extends Bloc<PfmpEvent, PfmpState> {
  final PfmpLoader _load;
  final PfmpCreator _create;
  bool _posting = false;
  int _loadGeneration = 0;
  PfmpCreationReceipt? _savedReceipt;
  bool get submissionPending => _posting;
  bool get creationNeedsReload => _savedReceipt != null;

  PfmpBloc({PfmpLoader? load, PfmpCreator? create})
    : _load = load ?? requestPfmp,
      _create = create ?? sendPfmp,
      super(const PfmpInitializeState()) {
    on<PfmpInitializeEvent>((event, emit) async {
      if (_posting) return;
      final generation = ++_loadGeneration;
      emit(const PfmpLoadingState());
      final rows = await _safeLoad(event.idEtudiant, event.idPfmp);
      if (generation != _loadGeneration) return;
      if (rows == null) {
        final receipt = _savedReceipt;
        emit(
          receipt == null
              ? const PfmpErrorState('Impossible de charger les PFMP.')
              : PfmpReloadErrorState(receipt),
        );
      } else {
        _savedReceipt = null;
        emit(PfmpSuccessState(rows));
      }
    });
    on<PfmpPostEvent>((event, emit) async {
      if (_posting || _savedReceipt != null) return;
      // A list request started before this POST must not replace its outcome.
      ++_loadGeneration;
      _posting = true;
      emit(const PfmpPostLoadingState());
      try {
        final receipt = await _create(event.informations);
        _savedReceipt = receipt;
        emit(PfmpPostSuccessState(receipt));
        final rows = await _safeLoad(receipt.idEtudiant, null);
        if (rows == null) {
          emit(PfmpReloadErrorState(receipt));
        } else {
          _savedReceipt = null;
          emit(PfmpSuccessState(rows));
        }
      } on PfmpRequestException catch (error) {
        emit(
          PfmpPostErrorState(
            error.message,
            outcomeUnknown: error.outcomeUnknown,
          ),
        );
      } catch (_) {
        emit(
          const PfmpPostErrorState(
            'Connexion interrompue. Vérifiez la liste avant de réessayer.',
            outcomeUnknown: true,
          ),
        );
      } finally {
        _posting = false;
      }
    });
  }

  Future<List<Pfmp?>?> _safeLoad(int studentId, int? pfmpId) async {
    try {
      return await _load(studentId, pfmpId);
    } catch (_) {
      return null;
    }
  }
}
