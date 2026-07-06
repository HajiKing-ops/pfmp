import 'dart:convert';
import 'package:http/browser_client.dart';

Future<({bool success, String message})> initialiserPresences() async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final url = Uri.parse('/api/presence/initialiser');

    final response = await client.post(
      url,
      headers: {'Accept': 'text/plain'},
    );
    final message = response.body.trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (
        success: true,
        message: message.isEmpty ? 'Presences initialisees' : message,
      );
    }

    return (
      success: false,
      message: message.isEmpty
          ? 'Erreur lors de l initialisation des presences'
          : message,
    );
  } catch (_) {
    return (
      success: false,
      message: 'Impossible d initialiser les presences',
    );
  } finally {
    client.close();
  }
}

class PresenceModification {
  final String dateJour;
  final String etat;

  const PresenceModification({
    required this.dateJour,
    required this.etat,
  });

  Map<String, dynamic> toJson() => {
        'dateJour': dateJour,
        'etat': etat,
        'retard': 0,
        'justification': false,
      };
}

Future<({bool success, String message})> modifierPresences({
  required int idEtudiant,
  required int idPfmp,
  required List<PresenceModification> modifications,
}) async {
  final client = BrowserClient()..withCredentials = true;

  try {
    if (idEtudiant <= 0) {
      return (
        success: false,
        message: 'Identifiant etudiant manquant',
      );
    }

    if (modifications.isEmpty) {
      return (
        success: false,
        message: 'Aucun jour selectionne',
      );
    }

    final url = Uri.parse('/api/presence/modify');
    final jours = modifications.map((modification) {
      return modification.toJson();
    }).toList();
    final Map<String, dynamic> data = {
      'idEtudiant': idEtudiant,
      'idUtilisateur': idEtudiant,
      'id_Utilisateur': idEtudiant,
      'studentId': idEtudiant,
      'idPfmp': idPfmp,
      'id_PFMP': idPfmp,
      'presences': jours,
      'jours': jours,
    };

    if (modifications.length == 1) {
      data.addAll(modifications.single.toJson());
    }

    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );
    final message = response.body.trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (
        success: true,
        message: message.isEmpty ? 'Presences modifiees' : message,
      );
    }

    if (response.statusCode == 404 || response.statusCode == 405) {
      return await _modifierPresencesAvecUpdateEndpoint(
        client: client,
        idEtudiant: idEtudiant,
        modifications: modifications,
      );
    }

    return (
      success: false,
      message: message.isEmpty
          ? 'Erreur lors de la modification des presences'
          : message,
    );
  } catch (_) {
    return (
      success: false,
      message: 'Impossible de modifier les presences',
    );
  } finally {
    client.close();
  }
}

Future<({bool success, String message})> _modifierPresencesAvecUpdateEndpoint({
  required BrowserClient client,
  required int idEtudiant,
  required List<PresenceModification> modifications,
}) async {
  int successCount = 0;
  final List<String> errors = [];

  for (final modification in modifications) {
    final response = await client.put(
      Uri.parse('/api/presence/update/$idEtudiant'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(modification.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      successCount++;
    } else {
      final message = response.body.trim();
      errors.add(
        '${modification.dateJour}: ${message.isEmpty ? response.statusCode.toString() : message}',
      );
    }
  }

  if (errors.isEmpty) {
    return (
      success: true,
      message: '$successCount presence(s) modifiee(s)',
    );
  }

  return (
    success: false,
    message: errors.join(' | '),
  );
}
