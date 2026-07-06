// Classe Evenement parente
class AuthentificationEvent {
  const AuthentificationEvent();
}

// Evenement de connexion à l'espace utilisateur, prend comme attribut le nom d'utilisateur et son mot de passe (hashé par la suite dans l'API)
class AuthentificationLoginEvent extends AuthentificationEvent {
  final String nomUser;
  final String pwd;

  const AuthentificationLoginEvent(this.nomUser, this.pwd) : super();
}

class AuthentificationLogoutEvent extends AuthentificationEvent {
  const AuthentificationLogoutEvent() : super();
}
