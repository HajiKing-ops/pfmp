/*
  Classe Demarche
  Attributs :
  - Nom de l'entreprise démarchée
  - SIRET de l'entreprise démarchée
  - Date de démarchage
  - Contact de l'entreprise démarchée
  - Statut actuel de la démarche (En attente, Refusé ou Accepté)
*/

class Demarche {
  String nomEntreprise;
  String siret;
  String dateDemarche;
  String contact;
  String statut;

  Demarche({
    required this.nomEntreprise,
    required this.siret,
    required this.dateDemarche,
    required this.contact,
    required this.statut,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  factory Demarche.fromJson(Map<String, dynamic> json) => Demarche(
    nomEntreprise: json['raisonSociale'],
    siret: json['siret'],
    dateDemarche: json['dateDemande'],
    contact: json['typeContact'],
    statut: json['statutDemande'],
  );
}
