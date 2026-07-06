/*
  Classe EntreeJournal
  Attributs :
  - Identifiant de l'entrée du journal
  - Identifiant de l'étudiant concerné
  - Date de saisie de l'entrée
  - Initialement prévu : Lien vers le fichier .txt du rapport ; Modifié : Rapport condensé
*/
class EntreeJournal {
  int id;
  int idEtudiant;
  int? idPfmp;
  String dateSaisie;
  String lienVersFichier;

  EntreeJournal({
    required this.id,
    required this.idEtudiant,
    this.idPfmp,
    required this.dateSaisie,
    required this.lienVersFichier,
  });

  // Lien avec les attributs de la classe correspondante dans l'API
  factory EntreeJournal.fromJson(Map<String, dynamic> json) => EntreeJournal(
    id: json['idRapportJournalier'],
    idEtudiant: json['idEtudiant'],
    idPfmp: json['id_PFMP'] ?? json['idPfmp'],
    dateSaisie: json['dateRapport'],
    lienVersFichier: json['lienVersFichier'],
  );
}
