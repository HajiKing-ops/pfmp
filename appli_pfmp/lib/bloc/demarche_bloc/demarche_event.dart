// Classe d'évènement parente
class DemarcheEvent {
  const DemarcheEvent();
}

// Evenement initial de l'affichage des démarches utilisateur, prend en attribut le token de l'utilisateur pour effectuer les requêtes à l'API
class DemarcheInitializeEvent extends DemarcheEvent {
  const DemarcheInitializeEvent() : super();
}

// Evenement de création de démarche, envoyant à l'API les informations de la nouvelle démarche
class DemarchePostEvent extends DemarcheEvent {
  final String nomEntreprise;
  final String siret;
  final String dateDemarche;
  final String contact;
  final String? statut;
  const DemarchePostEvent(
    this.nomEntreprise,
    this.siret,
    this.dateDemarche,
    this.contact,
    this.statut,
  ) : super();
}

// Evenement de modification de démarche existante, avec les nouvelles informations de cette dernière
class DemarchePutEvent extends DemarcheEvent {
  final String siret;
  final String dateDemarche;
  final String contact;
  final String statut;
  const DemarchePutEvent(
    this.siret,
    this.dateDemarche,
    this.contact,
    this.statut,
  ) : super();
}
