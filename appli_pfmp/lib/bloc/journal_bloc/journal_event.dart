// Classe d'évènement parente
class EntreeJournalEvent {
  const EntreeJournalEvent();
}

// Evenement initial d'affichage des entrées du journal de bord
class EntreeJournalInitializeEvent extends EntreeJournalEvent {
  final int idEtudiant;
  final int? idEntreeJournal;
  const EntreeJournalInitializeEvent(
    this.idEtudiant,
    this.idEntreeJournal,
  ) : super();
}

// Evenement de publication d'une nouvelle entrée dans le journal
class EntreeJournalPostEvent extends EntreeJournalEvent {
  final int idEtudiant;
  final String rapport;
  final String dateRapport;
  const EntreeJournalPostEvent(
    this.idEtudiant,
    this.rapport,
    this.dateRapport,
  ) : super();
}
