class StudentProfile {
  final String prenom;
  final String nom;
  final String dateNaissance;
  final String niveau;
  final String filiere;
  final String etablissement;

  const StudentProfile({
    required this.prenom,
    required this.nom,
    required this.dateNaissance,
    required this.niveau,
    required this.filiere,
    required this.etablissement,
  });

  String get fullName => '$prenom $nom'.trim();

  String get initials {
    final first = prenom.trim().isEmpty ? '' : prenom.trim()[0];
    final last = nom.trim().isEmpty ? '' : nom.trim()[0];
    final value = '$first$last'.toUpperCase();
    return value.isEmpty ? '?' : value;
  }

  StudentProfile copyWith({
    String? prenom,
    String? nom,
    String? dateNaissance,
    String? niveau,
    String? filiere,
    String? etablissement,
  }) {
    return StudentProfile(
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      niveau: niveau ?? this.niveau,
      filiere: filiere ?? this.filiere,
      etablissement: etablissement ?? this.etablissement,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      prenom: _readString(json, ['prenom', 'firstName']),
      nom: _readString(json, ['nom', 'lastName']),
      dateNaissance: _formatDate(
        _readString(json, ['dateNaissance', 'date_Naissance', 'birthDate']),
      ),
      niveau: _readString(json, ['niveau', 'level']),
      filiere: _readString(json, ['filiere', 'libelleFiliere']),
      etablissement: _readString(json, [
        'etablissement',
        'nomEtablissement',
        'school',
      ]),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'prenom': prenom,
      'nom': nom,
      'dateNaissance': dateNaissance,
      'niveau': niveau,
      'filiere': filiere,
      'etablissement': etablissement,
    };
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key] ?? json[_capitalize(key)];
    if (value != null) {
      return value.toString();
    }
  }
  return '';
}

String _formatDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }

  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}
