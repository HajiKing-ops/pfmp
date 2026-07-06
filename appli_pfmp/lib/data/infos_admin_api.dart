import 'dart:convert';
import 'package:appli_pfmp/model/admin_class_stats.dart';
import 'package:appli_pfmp/model/infos_admin.dart';
import 'package:http/browser_client.dart';

/*
  Requête de récupération des informations pour l'espace administrateur d'un établissement.
  Renvoie la liste des stages réalisés par les étudiants concernés et les statistiques générales de ces PFMP.
*/

Future<({List<StagiaireAdmin> stagiairesAdmin, StatsAdmin statsAdmin})>
requestInfosAdmin() async {
  try {
    // Route API
    final url = Uri.parse("/api/administrateur");
    
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
      // Renvoie la liste des PFMP en cours ou à venir et les statistiques globales
      final Map<String, dynamic> body = jsonDecode(response.body);
      return (
        stagiairesAdmin: (body['adminRowDto'] as List<dynamic>)
            .map((e) => StagiaireAdmin.fromJson(e as Map<String, dynamic>))
            .toList(),
        statsAdmin: StatsAdmin.fromJson(body['stat'] as Map<String, dynamic>),
      );
    } else {
      // Renvoie une liste de stages vides et des statistiques nulles
      return (
        stagiairesAdmin: <StagiaireAdmin>[],
        statsAdmin: StatsAdmin(
          stageTotal: 0,
          encours: 0,
          valide: 0,
          absencesTotal: 0,
        ),
      );
    }
  } catch ($e) {
    return (
      stagiairesAdmin: <StagiaireAdmin>[],
      statsAdmin: StatsAdmin(
        stageTotal: 0,
        encours: 0,
        valide: 0,
        absencesTotal: 0,
      ),
    );
  }
}

class AdminListApiResult<T> {
  final List<T> items;
  final String? errorMessage;

  const AdminListApiResult({
    required this.items,
    this.errorMessage,
  });

  bool get success => errorMessage == null;
}

Future<AdminListApiResult<AdminClassStats>> requestAdminClassStats() async {
  final client = BrowserClient()..withCredentials = true;
  const endpoints = [
    '/api/administrateur/classes/stats',
    '/api/administrateur/classes',
  ];

  try {
    for (var index = 0; index < endpoints.length; index++) {
      final response = await client.get(
        Uri.parse(endpoints[index]),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          final classes = body
              .whereType<Map<String, dynamic>>()
              .map(AdminClassStats.fromJson)
              .toList();
          return AdminListApiResult(
            items: await _hydrateClassLabels(client, classes),
          );
        }
        return const AdminListApiResult(
          items: [],
          errorMessage: 'Format de reponse invalide pour les classes',
        );
      }

      if (response.statusCode == 404) {
        if (index == endpoints.length - 1) {
          return const AdminListApiResult(items: []);
        }
        continue;
      }

      return AdminListApiResult(
        items: const [],
        errorMessage: _responseMessage(
          response.body,
          fallback: 'Impossible de charger les classes',
        ),
      );
    }
  } catch (_) {
    return const AdminListApiResult(
      items: [],
      errorMessage: 'Impossible de contacter le serveur',
    );
  } finally {
    client.close();
  }

  return const AdminListApiResult(items: []);
}

Future<List<AdminClassStats>> _hydrateClassLabels(
  BrowserClient client,
  List<AdminClassStats> classes,
) async {
  final hydrated = <AdminClassStats>[];

  for (final classe in classes) {
    if (classe.libelleClasse.trim().isNotEmpty) {
      hydrated.add(classe);
      continue;
    }

    final label = await _fetchClassLabel(client, classe);
    hydrated.add(
      label == null ? classe : classe.copyWith(libelleClasse: label),
    );
  }

  return hydrated;
}

Future<String?> _fetchClassLabel(
  BrowserClient client,
  AdminClassStats classe,
) async {
  try {
    final url = Uri(
      path: '/api/administrateur/recherche',
      queryParameters: {
        'idEtablissement': classe.idEtablissement.toString(),
        'idClasse': classe.idClasse.toString(),
      },
    );

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      return null;
    }

    final rows = body['adminRowDto'] ?? body['AdminRowDto'];
    if (rows is! List || rows.isEmpty) {
      return null;
    }

    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final label = row['libelleClasse'] ?? row['LibelleClasse'];
      if (label is String && label.trim().isNotEmpty) {
        return label.trim();
      }
    }
  } catch (_) {
    return null;
  }

  return null;
}

Future<AdminListApiResult<StagiaireAdmin>> requestAdminStudentsByClass({
  required int idEtablissement,
  required int idClasse,
}) async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final url = Uri(
      path: '/api/administrateur/recherche',
      queryParameters: {
        'idEtablissement': idEtablissement.toString(),
        'idClasse': idClasse.toString(),
      },
    );

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final rows = body['adminRowDto'] ?? body['AdminRowDto'];
        if (rows is List) {
          return AdminListApiResult(
            items: rows
                .whereType<Map<String, dynamic>>()
                .map(StagiaireAdmin.fromJson)
                .toList(),
          );
        }
      }

      return const AdminListApiResult(
        items: [],
        errorMessage: 'Format de reponse invalide pour les etudiants',
      );
    }

    if (response.statusCode == 404) {
      return const AdminListApiResult(items: []);
    }

    return AdminListApiResult(
      items: const [],
      errorMessage: _responseMessage(
        response.body,
        fallback: 'Impossible de charger les etudiants',
      ),
    );
  } catch (_) {
    return const AdminListApiResult(
      items: [],
      errorMessage: 'Impossible de contacter le serveur',
    );
  } finally {
    client.close();
  }
}

String _responseMessage(String body, {required String fallback}) {
  if (body.trim().isEmpty) {
    return fallback;
  }

  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'] ?? decoded['title'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded;
    }
  } catch (_) {
    return body;
  }

  return fallback;
}
