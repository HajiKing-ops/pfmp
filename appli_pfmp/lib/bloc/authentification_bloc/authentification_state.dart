import 'package:appli_pfmp/model/utilisateur.dart';

// Classe d'état parente
class AuthentificationState {
  const AuthentificationState();
}

// Etat de connexion à l'espace utilisateur réussie
class AuthentificationSuccessState extends AuthentificationState {
  final Utilisateur currentUser;
  const AuthentificationSuccessState(this.currentUser);
}

// Erreur lors de l'authentification, avec affichage de l'erreur
class AuthentificationErrorState extends AuthentificationState {
  final String error;
  const AuthentificationErrorState(this.error);
}

// Etat initial de l'authentification
class AuthentificationInitializeState extends AuthentificationState {
  const AuthentificationInitializeState();
}
