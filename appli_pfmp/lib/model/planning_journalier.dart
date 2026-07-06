/*
  Classe JourPlanning
  Attributs :
  - Jour de la semaine correspondant
  - Horaire de début de matinée
  - Horaire de fin de matinée
  - Horaire de début d'après-midi
  - Horaire de fin d'après-midi
  - Nombre total d'heures (initialement => minutes pour simplifier les calculs)

  Les horaires sont nullables car un stagiaire peut travailler le matin mais pas l'après-midi par exemple.
  Les autres conditions sont gérées au niveau de l'API.
*/
class JourPlanning {
  String jour;
  String? matinDebut;
  String? matinFin;
  String? apresMidiDebut;
  String? apresMidiFin;
  int totalHeures;

  JourPlanning({
    required this.jour,
    this.matinDebut,
    this.matinFin,
    this.apresMidiDebut,
    this.apresMidiFin,
    required this.totalHeures,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  factory JourPlanning.fromJson(Map<String, dynamic> json) => JourPlanning(
    jour: json['jour'],
    matinDebut: json['matinDebut'],
    matinFin: json['matinFin'],
    apresMidiDebut: json['apresMidiDebut'],
    apresMidiFin: json['apresMidiFin'],
    totalHeures: json['totalMinutes'],
  );
}
