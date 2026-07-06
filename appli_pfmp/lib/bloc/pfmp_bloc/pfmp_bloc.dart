import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/data/pfmp_api.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PfmpBloc extends Bloc<PfmpEvent, PfmpState> {
  // Etat par défaut : initialisation de l'état d'affichage des PFMP de l'étudiant
  PfmpBloc() : super(PfmpInitializeState()) {
    // Si l'évènement courant est l'affichage des PFMP
    on<PfmpInitializeEvent>((event, emit) async {
      // Emission de l'état de chargement des PFMP
      emit(PfmpLoadingState());

      // Stockage des PFMP récupérées via la requête à l'API
      List<Pfmp?>? pfmp = await requestPfmp(
        event.idEtudiant,
        event.idPfmp,
      );

      // Si la requête est fonctionnelle
      if (pfmp != null) {
        // Emission de l'état de succès de récupération des PFMP
        emit(PfmpSuccessState(pfmp));
      } else {
        // Emission de l'état d'erreur lors de la récupération des PFMP
        emit(PfmpErrorState(Error()));
      }
    });

    // Si l'évènement courant est la publication d'une nouvelle PFMP
    on<PfmpPostEvent>((event, emit) async {
      // Emission de l'état de chargement de l'envoi de la nouvelle PFMP
      emit(PfmpPostLoadingState());

      // Stockage des PFMP récupérées via la requête à l'API
      Pfmp? nouvelleEntree = await sendPfmp(event.informations);

      // Si la requête est fonctionnelle
      if (nouvelleEntree != null) {
        // Emission de l'état de confirmation de création de la nouvelle PFMP
        emit(PfmpPostSuccessState(nouvelleEntree));
      } else {
        // Emission de l'état d'erreur lors de la création de la nouvelle PFMP
        emit(PfmpPostErrorState(Error()));
      }
    });
  }
}
