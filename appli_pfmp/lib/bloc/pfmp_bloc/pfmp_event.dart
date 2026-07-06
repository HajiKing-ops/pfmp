// Classe d'évènement parente
class PfmpEvent {
  const PfmpEvent();
}

// Evenement initial d'affichage des PFMP de l'étudiant
class PfmpInitializeEvent extends PfmpEvent {
  final int idEtudiant;
  final int? idPfmp;
  const PfmpInitializeEvent(this.idEtudiant, this.idPfmp) : super();
}

// Evenement de saisie d'une nouvelle PFMP
class PfmpPostEvent extends PfmpEvent {
  final Map informations;
  const PfmpPostEvent(this.informations) : super();
}
