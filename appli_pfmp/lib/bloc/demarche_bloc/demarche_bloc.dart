import 'package:appli_pfmp/data/demarche_api.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_event.dart';
import 'package:appli_pfmp/bloc/demarche_bloc/demarche_state.dart';
import 'package:appli_pfmp/model/demarche.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DemarcheBloc extends Bloc<DemarcheEvent, DemarcheState> {
  // Etat par défaut : initialisation de l'état d'affichage des démarches
  DemarcheBloc() : super(DemarcheInitializeState()) {
    // Si l'évènement courant est l'affichage des démarches
    on<DemarcheInitializeEvent>((event, emit) async {
      // Emission de l'état de chargement des démarches
      emit(DemarcheLoadingState());

      // Stockage des données de la requête de récupération des démarches en BDD
      List<Demarche?>? demarches = await requestDemarche();

      // Si la requête renvoie quelque chose
      if (demarches != null) {
        // Emission de l'état de succès de récupération des démarches et affichage
        emit(DemarcheSuccessState(demarches));
      } else {
        // Emission de l'état d'erreur
        emit(DemarcheErrorState(Error()));
      }
    });

    // Si l'évènement courant est la création d'une nouvelle démarche
    on<DemarchePostEvent>((event, emit) async {
      // Formatage de la date de démarchage en yyyy-MM-dd. ".substring(0, 10)" pour ne pas avoir les spécifications horaires
      String dateDemarche = DateFormat(
        'yyyy-MM-dd',
      ).parse(event.dateDemarche).toString().substring(0, 10);

      // Emission de l'état de chargement d'envoi de la nouvelle démarche
      emit(DemarchePostLoadingState());

      // Stockage des informations envoyées lors de la requête à l'API
      Demarche? nouvelleDemarche = await sendDemarche(
        event.nomEntreprise,
        event.siret,
        dateDemarche,
        event.contact,
      );

      // Si la requête est fonctionnelle
      if (nouvelleDemarche != null) {
        // Emission de l'état de confirmation de création de démarche
        emit(DemarchePostSuccessState(nouvelleDemarche));
      } else {
        // Emission de l'état d'erreur de création de démarche
        emit(DemarchePostErrorState(Error()));
      }
    });

    // Si l'évènement courant est la modification d'une démarche existante
    on<DemarchePutEvent>((event, emit) async {
      // Emission de l'état de chargement d'envoi de la démarche modifiée
      emit(DemarchePutLoadingState());

      // Stockage des informations envoyées lors de la requête à l'API
      Demarche? demarcheModifiee = await modifyDemarche(
        event.siret,
        event.dateDemarche,
        event.contact,
        event.statut,
      );

      // Si la démarche est fonctionnelle
      if (demarcheModifiee != null) {
        // Emission de l'état de confirmation de modification de la démarche
        emit(DemarchePutSuccessState(demarcheModifiee));
      } else {
        // Emission de l'état d'erreur de modification de démarche
        emit(DemarchePutErrorState(Error()));
      }
    });
  }
}
