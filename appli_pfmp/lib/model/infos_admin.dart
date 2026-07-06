/*
  Ce fichier contient les classes relatives aux informations visibles dans l'espace adminisatrateur.
*/

/*
  Classe StagiaireAdmin
  Attributs :
  - Nom du stagiaire
  - Prénom du stagiaire
  - Nom de la filière du stagiaire
  - Nom de l'entreprise où se déroule le stage
  - Nom du maître de stage
  - Prénom du maître de stage
  - Numéro de téléphone du maître de stage
  - Date de début du stage
  - Date de fin du stage
  - Nombre de présence du stagiaire
  - Nombre d'absences du stagiaire
  - Nombre de jours restants
  - Statut du journal du stagiaire (false : Incomplet, true : Validé)
  - Identifiant de la PFMP
  - Identifiant de l'établissement
  - Identifiant de la classe du stagiaire
  - Nom de la classe du stagiaire
*/
class PresenceJourAdmin {
  final String dateJour;
  final String etat;
  final int retard;
  final bool justification;

  const PresenceJourAdmin({
    required this.dateJour,
    required this.etat,
    required this.retard,
    required this.justification,
  });

  factory PresenceJourAdmin.fromJson(Map<String, dynamic> json) =>
      PresenceJourAdmin(
        dateJour: json['dateJour'] ?? json['DateJour'] ?? '',
        etat: json['etat'] ?? json['Etat'] ?? '',
        retard: json['retard'] ?? json['Retard'] ?? 0,
        justification:
            json['justification'] ?? json['Justification'] ?? false,
      );
}

class PlanningJourAdmin {
  final String jour;

  const PlanningJourAdmin({required this.jour});

  factory PlanningJourAdmin.fromJson(Map<String, dynamic> json) =>
      PlanningJourAdmin(
        jour: json['jour'] ?? json['Jour'] ?? '',
      );
}

class StagiaireAdmin {
  final String nom;
  final String prenom;
  final String libelleFiliere;
  final String entreprise;
  final String nomMaitreDeStage;
  final String prenomMaitreDeStage;
  final String numTelephone;
  final String dateDebut;
  final String dateFin;
  final int presence;
  final int absence;
  final int restants;
  final bool status;
  final int? idEtudiant;
  final int idPfmp;
  final int idEtablissement;
  final int idClasse;
  final String libelleClasse;
  final List<PresenceJourAdmin> tablePresence;
  final List<PlanningJourAdmin> planningJours;

  StagiaireAdmin({
    required this.nom,
    required this.prenom,
    required this.libelleFiliere,
    required this.entreprise,
    required this.nomMaitreDeStage,
    required this.prenomMaitreDeStage,
    required this.numTelephone,
    required this.dateDebut,
    required this.dateFin,
    required this.presence,
    required this.absence,
    required this.restants,
    required this.status,
    this.idEtudiant,
    required this.idPfmp,
    required this.idEtablissement,
    required this.idClasse,
    required this.libelleClasse,
    required this.tablePresence,
    required this.planningJours,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value);
      }
    }
    return null;
  }

  static List<PresenceJourAdmin> _readTablePresence(
    Map<String, dynamic> json,
  ) {
    final value = json['tablePresence'] ?? json['TablePresence'];

    if (value is! List) {
      return <PresenceJourAdmin>[];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(PresenceJourAdmin.fromJson)
        .toList();
  }

  static List<PlanningJourAdmin> _readPlanningJours(
    Map<String, dynamic> json,
  ) {
    final value = json['planningJours'] ??
        json['PlanningJours'] ??
        json['joursPlanning'] ??
        json['JoursPlanning'];

    if (value is! List) {
      return <PlanningJourAdmin>[];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(PlanningJourAdmin.fromJson)
        .toList();
  }

  factory StagiaireAdmin.fromJson(Map<String, dynamic> json) => StagiaireAdmin(
    nom: json['nom'],
    prenom: json['prenom'],
    libelleFiliere: json['libelleFiliere'],
    entreprise: json['entreprise'],
    nomMaitreDeStage: json['nomMaitreDeStage'],
    prenomMaitreDeStage: json['prenomMaitreDeStage'],
    numTelephone: json['numTelephone'],
    dateDebut: json['dateDebut'],
    dateFin: json['dateFin'],
    presence: json['presence'],
    absence: json['absence'],
    restants: json['restants'],
    status: json['status'],
    idEtudiant: _readInt(json, [
      'idEtudiant',
      'id_Utilisateur',
      'idUtilisateur',
      'studentId',
    ]),
    idPfmp: json['id_PFMP'],
    idEtablissement: json['idEtablissement'],
    idClasse: json['idClasse'],
    libelleClasse: json['libelleClasse'],
    tablePresence: _readTablePresence(json),
    planningJours: _readPlanningJours(json),
  );
}

/*
  Classe StatsAdmin
  Attributs :
  - Nombre total de stages en cours dans l'établissement
  - Nombre de stages En cours
  - Nombre de stages validés
  - Nombre total d'absences des stagiaires
*/
class StatsAdmin {
  final int stageTotal;
  final int encours;
  final int valide;
  final int absencesTotal;

  StatsAdmin({
    required this.stageTotal,
    required this.encours,
    required this.valide,
    required this.absencesTotal,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  factory StatsAdmin.fromJson(Map<String, dynamic> json) => StatsAdmin(
    stageTotal: json['stageTotal'],
    encours: json['encours'],
    valide: json['valide'],
    absencesTotal: json['absencesTotal'],
  );
}
