import 'package:appli_pfmp/bloc/journal_bloc/journal_event.dart';
import 'package:appli_pfmp/bloc/journal_bloc/journal_state.dart';
import 'package:appli_pfmp/data/journal_api.dart';
import 'package:appli_pfmp/model/journal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EntreeJournalBloc extends Bloc<EntreeJournalEvent, EntreeJournalState> {
  // Etat par défaut : initialisation de l'état d'affichage des entrées du journal de bord
  EntreeJournalBloc() : super(EntreeJournalInitializeState()) {
    // Si l'évènement courant est l'affichage des entrées du journal
    on<EntreeJournalInitializeEvent>((event, emit) async {
      // Emission de l'état de chargement des entrées
      emit(EntreeJournalLoadingState());

      // Stockage des entrées récupérées via la requête à l'API
      List<EntreeJournal?>? entreesJournal = await requestJournal(
        event.idEtudiant,
      );

      // Si la requête est fonctionnelle
      if (entreesJournal != null) {
        // Emission de l'état de confirmation de récupération des entrées du journal
        emit(EntreeJournalSuccessState(entreesJournal));
      } else {
        // Emission de l'état d'erreur lors de la récupération des entrées du journal
        emit(EntreeJournalErrorState(Error()));
      }
    });

    // Si l'évènement courant est la publication d'une nouvelle entrée dans le journal de bord
    on<EntreeJournalPostEvent>((event, emit) async {
      // Formatage de la date de saisie au format aaaa-mm-jj
      String dateJour = DateFormat(
        'yyyy-MM-dd',
      ).parse(DateTime.now().toString()).toString();

      // Emission de l'état de chargement d'envoi de la nouvelle entrée
      emit(EntreeJournalPostLoadingState());

      // Stockage des informations envoyées pour la requête à l'API
      EntreeJournal? nouvelleEntree = await sendJournal(
        event.rapport,
        dateJour.substring(0, 10),
      );

      // Si la requête est fonctionnelle
      if (nouvelleEntree != null) {
        // Emission de l'état de succès de saisie dans le journal
        emit(EntreeJournalPostSuccessState(nouvelleEntree));
      } else {
        // Emission de l'état d'erreur de saisie de nouvelle entrée dans le journal
        emit(EntreeJournalPostErrorState(Error()));
      }
    });
  }
}
