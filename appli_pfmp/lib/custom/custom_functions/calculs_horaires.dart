
/*
  Il s'agit des fonctions relatives aux calculs d'horaires, notamment utilisées pour le formulaire de création de PFMP
*/

// Convertit "HH:mm" en nombre total de minutes
int? toMinutes(String horaire) {
  if (horaire.isEmpty) {
    return null;
  }

  final parts = horaire.split(':');
  if (parts.length != 2) {
    return null;
  }

  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  return h! * 60 + m!;
}

// Prend en paramètre des listes de 2 chaînes de caractères, et renvoie leur cumul total en minutes
String totalHoraires({
  List<String>? horairesMatin,
  List<String>? horairesApresMidi,
}) {
  int totalMinutes = 0;

  if (horairesMatin != null &&
      horairesMatin.length == 2 &&
      horairesMatin[0].isNotEmpty &&
      horairesMatin[1].isNotEmpty) {
    final debut = toMinutes(horairesMatin[0]);
    final fin = toMinutes(horairesMatin[1]);
    if (debut != null && fin != null) {
      totalMinutes += (fin - debut);
    }
  }

  if (horairesApresMidi != null &&
      horairesApresMidi.length == 2 &&
      horairesApresMidi[0].isNotEmpty &&
      horairesApresMidi[1].isNotEmpty) {
    final debut = toMinutes(horairesApresMidi[0]);
    final fin = toMinutes(horairesApresMidi[1]);
    if (debut != null && fin != null) {
      totalMinutes += (fin - debut);
    }
  }

  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return "$h:${m.toString().padLeft(2, '0')}";
}

// Calcule le total de minutes hebdomadaires travaillées dans un planning donnée en paramètre
int totalHebdo(List planning) {
  int totalMinutes = 0;
  for (Map jour in planning) {
    totalMinutes += (jour["totalMinutes"] as num).toInt();
  }
  return totalMinutes;
}
