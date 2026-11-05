import 'dart:convert';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/pfmp_creation_receipt.dart';
import 'package:http/http.dart' as http;
import 'package:appli_pfmp/data/http_client.dart';

class PfmpRequestException implements Exception {
  final String message;
  final bool outcomeUnknown;
  const PfmpRequestException(this.message, {this.outcomeUnknown = false});
  @override
  String toString() => message;
}

String _errorMessage(http.Response response) {
  try {
    final value = jsonDecode(response.body);
    if (value is String && value.trim().isNotEmpty) return value;
    if (value is Map) {
      for (final key in ['message', 'error', 'title']) {
        if (value[key] is String) return value[key] as String;
      }
    }
  } catch (_) {
    if (response.body.trim().isNotEmpty && !response.body.contains('<')) {
      return response.body;
    }
  }
  return 'La demande a été refusée (${response.statusCode}).';
}

Future<List<Pfmp?>?> requestPfmp(
  int idEtudiant,
  int? idPfmp, {
  http.Client? client,
}) async {
  final transport = client ?? createHttpClient();
  try {
    final suffix = idPfmp == null ? '' : '/$idPfmp';
    final response = await transport.get(
      Uri.parse('/api/pfmp/recherche/$idEtudiant$suffix'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 404) return [];
    if (response.statusCode != 200) return null;
    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => Pfmp.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return null;
  } finally {
    if (client == null) transport.close();
  }
}

Future<PfmpCreationReceipt> sendPfmp(
  Map informations, {
  http.Client? client,
}) async {
  final transport = client ?? createHttpClient();
  try {
    final response = await transport.post(
      Uri.parse('/api/pfmp/complete'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(informations),
    );
    if (response.statusCode != 200) {
      throw PfmpRequestException(
        _errorMessage(response),
        outcomeUnknown: response.statusCode >= 500,
      );
    }
    try {
      return PfmpCreationReceipt.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      throw const PfmpRequestException(
        'Réponse illisible. La PFMP peut avoir été enregistrée : vérifiez la liste avant de réessayer.',
        outcomeUnknown: true,
      );
    }
  } on PfmpRequestException {
    rethrow;
  } catch (_) {
    throw const PfmpRequestException(
      'Connexion interrompue. La PFMP peut avoir été enregistrée : vérifiez la liste avant de réessayer.',
      outcomeUnknown: true,
    );
  } finally {
    if (client == null) transport.close();
  }
}
