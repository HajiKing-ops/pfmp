/// Compact response of POST /api/pfmp/complete; details come from GET.
class PfmpCreationReceipt {
  final int idPfmp;
  final int idEtudiant;
  final int idPlanning;
  final int idAdministrateur;
  final String siret;
  final String? dateDebut;
  final String? dateFin;

  const PfmpCreationReceipt({
    required this.idPfmp,
    required this.idEtudiant,
    required this.idPlanning,
    required this.idAdministrateur,
    required this.siret,
    required this.dateDebut,
    required this.dateFin,
  });

  factory PfmpCreationReceipt.fromJson(Map<String, dynamic> json) {
    final id = json['idPfmp'] as int;
    if (id <= 0) throw const FormatException('Invalid PFMP identifier');
    return PfmpCreationReceipt(
      idPfmp: id,
      idEtudiant: json['idEtudiant'] as int,
      idPlanning: json['id_Planning'] as int,
      idAdministrateur: json['idAdministrateur'] as int,
      siret: json['siret'] as String,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
    );
  }
}
