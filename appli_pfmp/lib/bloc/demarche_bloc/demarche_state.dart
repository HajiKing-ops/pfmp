import 'package:appli_pfmp/model/demarche.dart';

// Classe d'état parente
class DemarcheState {
  const DemarcheState();
}

// Etat initial des démarches
class DemarcheInitializeState extends DemarcheState {
  const DemarcheInitializeState();
}

// Etat de chargement des informations des démarches
class DemarcheLoadingState extends DemarcheState {
  const DemarcheLoadingState();
}

// Etat de succès de récupération des démarches, qui renvoie donc ces dernières
class DemarcheSuccessState extends DemarcheState {
  final List<Demarche?>? demarches;
  const DemarcheSuccessState(this.demarches);
}

// Erreur de récupération des données des démarches de l'utilisateur
class DemarcheErrorState extends DemarcheState {
  final Error error;
  const DemarcheErrorState(this.error);
}

// Etat de chargement de l'envoi des informations de la nouvelle démarche
class DemarchePostLoadingState extends DemarcheState {
  const DemarchePostLoadingState();
}

// Etat de succès de création de démarche
class DemarchePostSuccessState extends DemarcheState {
  final Demarche nouvelleDemarche;
  const DemarchePostSuccessState(this.nouvelleDemarche);
}

// Etat de refus de création de démarche
class DemarchePostErrorState extends DemarcheState {
  final Error error;
  const DemarchePostErrorState(this.error);
}

// Etat de chargement de l'envoi des nouvelles informations de la démarche existante
class DemarchePutLoadingState extends DemarcheState {
  const DemarchePutLoadingState();
}

// Etat de succès de modification de démarche, création d'une nouvelle instance de cette démarche
class DemarchePutSuccessState extends DemarcheState {
  final Demarche demarcheModifiee;
  const DemarchePutSuccessState(this.demarcheModifiee);
}

// Erreur lors de la modification de la démarche
class DemarchePutErrorState extends DemarcheState {
  final Error error;
  const DemarchePutErrorState(this.error);
}
