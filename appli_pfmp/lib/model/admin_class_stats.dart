class AdminClassStats {
  final int idEtablissement;
  final int idClasse;
  final String libelleClasse;
  final String libelleFiliere;
  final int nombreEleves;
  final int enCours;
  final int presence;
  final int absence;
  final int tauxPresence;

  const AdminClassStats({
    required this.idEtablissement,
    required this.idClasse,
    required this.libelleClasse,
    required this.libelleFiliere,
    required this.nombreEleves,
    required this.enCours,
    required this.presence,
    required this.absence,
    required this.tauxPresence,
  });

  String get displayName {
    final value = libelleClasse.trim();
    if (value.isNotEmpty) {
      return value;
    }
    final filiere = libelleFiliere.trim();
    if (filiere.isNotEmpty) {
      return filiere;
    }
    return 'Classe $idClasse';
  }

  AdminClassStats copyWith({
    int? idEtablissement,
    int? idClasse,
    String? libelleClasse,
    String? libelleFiliere,
    int? nombreEleves,
    int? enCours,
    int? presence,
    int? absence,
    int? tauxPresence,
  }) {
    return AdminClassStats(
      idEtablissement: idEtablissement ?? this.idEtablissement,
      idClasse: idClasse ?? this.idClasse,
      libelleClasse: libelleClasse ?? this.libelleClasse,
      libelleFiliere: libelleFiliere ?? this.libelleFiliere,
      nombreEleves: nombreEleves ?? this.nombreEleves,
      enCours: enCours ?? this.enCours,
      presence: presence ?? this.presence,
      absence: absence ?? this.absence,
      tauxPresence: tauxPresence ?? this.tauxPresence,
    );
  }

  factory AdminClassStats.fromJson(Map<String, dynamic> json) {
    return AdminClassStats(
      idEtablissement: _readInt(json, ['idEtablissement', 'IdEtablissement']),
      idClasse: _readInt(json, ['idClasse', 'IdClasse']),
      libelleClasse: _readString(json, ['libelleClasse', 'LibelleClasse']),
      libelleFiliere: _readString(json, ['libelleFiliere', 'LibelleFiliere']),
      nombreEleves: _readInt(json, ['nombreEleves', 'NombreEleves']),
      enCours: _readInt(json, ['enCours', 'EnCours']),
      presence: _readInt(json, ['presence', 'Presence']),
      absence: _readInt(json, ['absence', 'Absence']),
      tauxPresence: _readInt(json, ['tauxPresence', 'TauxPresence']),
    );
  }
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
  }
  return 0;
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString();
    }
  }
  return '';
}
