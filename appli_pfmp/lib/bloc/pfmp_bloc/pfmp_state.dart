import 'package:appli_pfmp/model/pfmp.dart';

// Classe d'état parente
class PfmpState {
  const PfmpState();
}

// Etat initial de l'affichage des PFMP de l'utilisateur
class PfmpInitializeState extends PfmpState {
  const PfmpInitializeState();
}

// Etat de chargement des PFMP
class PfmpLoadingState extends PfmpState {
  const PfmpLoadingState();
}

// Etat de succès de récupération des PFMP en BDD
class PfmpSuccessState extends PfmpState {
  final List<Pfmp?> pfmp;
  const PfmpSuccessState(this.pfmp);
}

// Etat d'erreur de récupération des PFMP
class PfmpErrorState extends PfmpState {
  final Error error;
  const PfmpErrorState(this.error);
}

// Etat de chargement de la publication d'une nouvelle PFMP
class PfmpPostLoadingState extends PfmpState {
  const PfmpPostLoadingState();
}

// Etat de confirmation de la création d'une nouvelle PFMP
class PfmpPostSuccessState extends PfmpState {
  final Pfmp nouvelleEntree;
  const PfmpPostSuccessState(this.nouvelleEntree);
}

// Etat d'erreur lors de la création d'une PFMP
class PfmpPostErrorState extends PfmpState {
  final Error error;
  const PfmpPostErrorState(this.error);
}
