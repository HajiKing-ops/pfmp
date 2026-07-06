import 'dart:convert';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:http/browser_client.dart';

/*
  Ce fichier contient les requêtes relatives à la gestion des PFMP de l'étudiant.
*/

/*
  Requête de récupération des PFMP de l'étudiant, prend en paramètre l'identifiant de l'étudiant, son token et un identifiant de PFMP optionnel.
  Renvoie la liste de toutes les PFMP réalisées et en cours. Si un identifiant de PFMP est inscrit, renvoie la PFMP souhaitée.
*/
Future<List<Pfmp?>?> requestPfmp(
  int idEtudiant,
  int? idPfmp,
) async {
  try {
    Uri? url;

    // Si aucune PFMP n'est spécifiée
    if (idPfmp == null) {
      url = Uri.parse(
        "/api/pfmp/recherche/$idEtudiant",
      );
    } else {
      // Si une PFMP est spécifiée
      url = Uri.parse(
        "/api/pfmp/recherche/$idEtudiant/$idPfmp",
      );
    }

    final client = BrowserClient()..withCredentials = true;

    // Résultat de la requête GET à l'API
    final response = await client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    // Si la requête renvoie le code de statut 200 : OK, ou requête réussie
    if (response.statusCode == 200) {
      // Renvoie la liste ds PFMP de l'étudiant
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Pfmp.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      return [];
    }
  } catch ($e) {
    return null;
  }
}

/*
  Requête de création de PFMP, prend en paramètre le token de l'étudiant et les informations de la PFMP créée.
  Renvoie la PFMP nouvellement créée.
*/
Future<Pfmp?> sendPfmp(Map informations) async {
  try {
    // Route API
    final url = Uri.parse("/api/pfmp/complete");

    // Contenu JSON envoyé
    Map data = informations;
    var body = jsonEncode(data);

    final client = BrowserClient()..withCredentials = true;

    // Résultat de la requête POST à l'API
    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );

    // Si la requête renvoie le code de statut 200 : OK, ou requête réussie
    if (response.statusCode == 200) {
      // Renvoie la PFMP créée
      Map<String, dynamic> result = jsonDecode(response.body);
      return Pfmp.fromJson(result);
    }
  } catch ($e) {
    return null;
  }
  return null;
}
