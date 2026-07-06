import 'dart:convert';
import 'package:appli_pfmp/model/journal.dart';
import 'package:http/browser_client.dart';

class JournalAlertResult {
  final bool success;
  final bool journalExiste;
  final String message;

  const JournalAlertResult({
    required this.success,
    required this.journalExiste,
    required this.message,
  });
}

Future<JournalAlertResult> checkJournalAlerte() async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final url = Uri.parse('/api/journal/alerte');

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final journalExiste =
          result['journalExiste'] == true || result['JournalExiste'] == true;

      return JournalAlertResult(
        success: true,
        journalExiste: journalExiste,
        message: journalExiste
            ? 'Journal deja renseigne aujourd hui'
            : 'Tu dois remplir ton journal de bord aujourd hui',
      );
    }

    return JournalAlertResult(
      success: false,
      journalExiste: true,
      message: response.body.trim().isEmpty
          ? 'Impossible de verifier le journal'
          : response.body,
    );
  } catch (_) {
    return const JournalAlertResult(
      success: false,
      journalExiste: true,
      message: 'Impossible de verifier le journal',
    );
  } finally {
    client.close();
  }
}

/*
  Ce fichier contient les requêtes relatives au traitement du journal de bord.
*/

/*
  Requête de récupération des entrées du journal de bord de l'étudiant, prend en paramètre son identifiant et son token.
  Renvoie les entrées associées à la PFMP en cours de l'étudiant spécifié.
*/
Future<List<EntreeJournal?>?> requestJournal(
  int idEtudiant,
) async {
  try {
    // Route API
    final url = Uri.parse("/api/journal");

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
      // Renvoie la liste des entrées du journal de bord
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((e) => EntreeJournal.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  } catch ($e) {
    return null;
  }
}

/*
  Requête de saisie d'une entrée dans le journal de bord, prend en paramètre le résumé du rapport, sa date de saisie (la date de requête) et le token de l'utilisateur.
  Renvoie le journal saisi.
*/
Future<EntreeJournal?> sendJournal(
  String rapport,
  String dateRapport,
) async {
  try {
    // Route API
    final url = Uri.parse("/api/journal");

    // Contenu JSON envoyé
    Map data = {
      "LienVersFichier": rapport,
      "dateRapport": dateRapport.substring(0, 10),
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
      // Renvoie la nouvelle entrée du journal de bord
      Map<String, dynamic> result = jsonDecode(response.body);
      return EntreeJournal.fromJson(result);
    }
  } catch ($e) {
    return null;
  }
  return null;
}
