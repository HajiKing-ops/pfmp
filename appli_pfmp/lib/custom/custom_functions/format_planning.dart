import 'package:appli_pfmp/custom/custom_functions/calculs_horaires.dart';

/*
  Ce fichier contient la fonction de formatage du planning Flutter créé dans 'appli_pfmp/application/formulaire_nouvelle_pfmp.dart'.
  L'intérêt est de le rendre compatible avec le fomat attendu dans l'API, notamment le format d'horaires.
*/

List formatApiPlanning(Map<dynamic, dynamic> planning) {
  List liste = [];

  for (MapEntry jour in planning.entries) {
    Map horairesPlanning = {};
    horairesPlanning["jour"] = jour.key;

    for (var horaire in (jour.value as Map).entries) {
      horairesPlanning[horaire.key] = horaire.value;
    }

    horairesPlanning["totalMinutes"] = toMinutes(
      totalHoraires(
        horairesMatin: [
          horairesPlanning["matinDebut"] ?? "",
          horairesPlanning["matinFin"] ?? "",
        ],
        horairesApresMidi: [
          horairesPlanning["apresMidiDebut"] ?? "",
          horairesPlanning["apresMidiFin"] ?? "",
        ],
      ),
    )!;

    liste.add(horairesPlanning);
  }

  return liste;
}
