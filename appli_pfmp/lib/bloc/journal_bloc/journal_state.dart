import 'package:appli_pfmp/model/journal.dart';

// Classe d'état parente
class EntreeJournalState {
  const EntreeJournalState();
}

// Etat initial d'affichage des entrées du journal
class EntreeJournalInitializeState extends EntreeJournalState {
  const EntreeJournalInitializeState();
}

// Etat de chargement des entrées du journal
class EntreeJournalLoadingState extends EntreeJournalState {
  const EntreeJournalLoadingState();
}

// Etat de succès de récupération des entrées du journal de bord
class EntreeJournalSuccessState extends EntreeJournalState {
  final List<EntreeJournal?>? entreesJournal;
  const EntreeJournalSuccessState(this.entreesJournal);
}

// Etat d'échec de la récupération des entrées du journal
class EntreeJournalErrorState extends EntreeJournalState {
  final Error error;
  const EntreeJournalErrorState(this.error);
}

// Etat de chargement de l'envoi de la nouvelle entrée
class EntreeJournalPostLoadingState extends EntreeJournalState {
  const EntreeJournalPostLoadingState();
}

// Etat de confirmation d'envoi de la nouvelle entrée
class EntreeJournalPostSuccessState extends EntreeJournalState {
  final EntreeJournal nouvelleEntree;
  const EntreeJournalPostSuccessState(this.nouvelleEntree);
}

// Etat d'erreur lors de l'envoi de la nouvelle entrée
class EntreeJournalPostErrorState extends EntreeJournalState {
  final Error error;
  const EntreeJournalPostErrorState(this.error);
}
