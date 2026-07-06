import 'package:appli_pfmp/model/planning_journalier.dart';

/*
  Classe Pfmp
  Attributs :
  - Date de début du stage
  - Date de fin du stage
  - Identifiant du planning associé
  - SIRET de l'entreprise concernée
  - Identifiant de l'étudiant stagiaire
  - Identifiant de la PFMP
  - Nombre de jours restants avant la fin du stage
  - Nom de l'entreprise concernée
  - Nombre total de semaines en stage
  - Prénom du maître de stage
  - Nom du maître de stage
  - Fonction du maître de stage dans l'entreprise
  - Numéro de téléphone du maître de stage
  - Adresse mail du maître de stage
  - Planning hebdomadaire du stagiaire sous forme de liste
*/
class Pfmp {
  String dateDebut;
  String dateFin;
  int idPlanning;
  String siret;
  int idEtudiant;
  int idPfmp;
  int joursRestants;
  String raisonSociale;
  int nbSemaines;
  String prenomMaitreStage;
  String nomMaitreStage;
  String fonctionMaitreStage;
  String telephoneMaitreStage;
  String emailMaitreStage;
  List<JourPlanning> planning;

  Pfmp({
    required this.dateDebut,
    required this.dateFin,
    required this.idPlanning,
    required this.siret,
    required this.idEtudiant,
    required this.idPfmp,
    required this.joursRestants,
    required this.raisonSociale,
    required this.nbSemaines,
    required this.prenomMaitreStage,
    required this.nomMaitreStage,
    required this.fonctionMaitreStage,
    required this.telephoneMaitreStage,
    required this.emailMaitreStage,
    required this.planning,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  factory Pfmp.fromJson(Map<String, dynamic> json) => Pfmp(
    dateDebut: json['dateDebut'],
    dateFin: json['dateFin'],
    idPlanning: json['id_Planning'],
    siret: json['siret'],
    idEtudiant: json['idEtudiant'],
    idPfmp: json['idPfmp'],
    joursRestants: json['jourRestants'],
    raisonSociale: json['raisonSociale'],
    nbSemaines: json['semaine'],
    prenomMaitreStage: json['prenomMaitreStage'],
    nomMaitreStage: json['nomMaitreStage'],
    fonctionMaitreStage: json['fonctionMaitreStage'],
    telephoneMaitreStage: json['telephoneMaitreStage'],
    emailMaitreStage: json['emailMaitreStage'],
    planning: (json['planningJours'] as List<dynamic>)
        .map((e) => JourPlanning.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
