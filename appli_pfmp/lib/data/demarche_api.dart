import 'dart:convert';
import 'package:appli_pfmp/model/demarche.dart';
import 'package:http/browser_client.dart';

/* 
  Ce fichier contient les 3 requêtes API relatives aux démarches de recherche d'entreprises.
*/

/*
  Requête de récupération de démarches existantes, prend en paramètre le token de l'utilisateur connecté, qui sera inscrit dans le header 'Authorization' de la requête.
  Renvoie la liste (possiblement vide) des démarches de cet utilisateur.
*/
Future<List<Demarche?>?> requestDemarche() async {
  try {
    // Route API
    final url = Uri.parse("/api/demarches");

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
      // Renvoie la liste des démarches de recherche d'entreprises réalisées par l'étudiant
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((e) => Demarche.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  } catch ($e) {
    return null;
  }
}

/*
  Requête de création d'une nouvelle démarche, prend en paramètre les informations de la démarche créée et le token de l'utilisateur.
  Renvoie la démarche créée.
*/
Future<Demarche?> sendDemarche(
  String nomEntreprise,
  String siret,
  String dateDemarche,
  String contact,
) async {
  try {
    // Route API
    final url = Uri.parse("/api/demarches/$siret");

    // Contenu JSON envoyé
    Map data = {
      "raisonSociale": nomEntreprise,
      "TypeContact": contact,
      "DateDemande": dateDemarche,
      "StatutDemande": "En attente",
    };
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
      // Renvoie la démarche nouvellement créée
      Map<String, dynamic> result = jsonDecode(response.body);
      return Demarche.fromJson(result);
    }
  } catch ($e) {
    return null;
  }
  return null;
}

/*
  Requête de modification de démarche existante, prend en paramètre les attributs de la démarche modifiés (ou non) et le token de l'utilisateur.
  Renvoie la démarche modifiée.
*/
Future<Demarche?> modifyDemarche(
  String? siret,
  String? dateDemarche,
  String? contact,
  String? statut,
) async {
  try {
    // Route API
    final url = Uri.parse(
      "/api/demarches/modify/$siret",
    );

    // Contenu JSON envoyé
    Map data = {
      "TypeContact": contact,
      "DateDemande": dateDemarche,
      "StatutDemande": statut,
    };
    var body = jsonEncode(data);

    final client = BrowserClient()..withCredentials = true;

    // Résultat de la requête PUT à l'API
    final response = await client.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: body,
    );

    // Si la requête renvoie le code de statut 200 : OK, ou requête réussie
    if (response.statusCode == 200) {
      // Renvoie la démarche modifiée
      Map<String, dynamic> result = jsonDecode(response.body);
      return Demarche.fromJson(result);
    }
  } catch ($e) {
    return null;
  }
  return null;
}
