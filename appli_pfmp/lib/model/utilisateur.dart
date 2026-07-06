/*
  Classe Utilisateur
  Attributs :
  - Identifiant de l'utilisateur
  - Nom de l'utilisateur
  - Prénom de l'utilisateur
  - Rôle de l'utilisateur (Etudiant, Enseignant ou Administrateur)
  - RefreshToken (dure 7 jours)
  - AccessToken (pour effectuer les requêtes à l'API, dure 15 minutes)
*/
class Utilisateur {
  int id;
  String nom;
  String prenom;
  String role;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  factory Utilisateur.fromJson(Map<String, dynamic> json) => Utilisateur(
    id: json['id_Utilisateur'],
    nom: json['nom'],
    prenom: json['prenom'],
    role: json['role'],
  );
}
