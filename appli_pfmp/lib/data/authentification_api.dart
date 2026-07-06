import 'dart:convert';

import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:http/browser_client.dart';

class AuthRequestResult {
  final Utilisateur? user;
  final String? errorMessage;

  const AuthRequestResult({this.user, this.errorMessage});

  bool get success => user != null;
}

Future<bool> logout() async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final url = Uri.parse('/api/logout');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (_) {
    return false;
  } finally {
    client.close();
  }
}

Future<AuthRequestResult> loginRequest(String login, String pwd) async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final url = Uri.parse('/api/login');
    final body = jsonEncode({'login': login, 'pwd': pwd});

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthRequestResult(user: Utilisateur.fromJson(result));
    }

    if (response.statusCode == 400) {
      return const AuthRequestResult(
        errorMessage: 'Veuillez saisir un login et un mot de passe',
      );
    }

    if (response.statusCode == 401) {
      return const AuthRequestResult(
        errorMessage: 'Login ou mot de passe incorrect',
      );
    }

    return AuthRequestResult(
      errorMessage: _responseMessage(
        response.body,
        fallback: 'Connexion impossible',
      ),
    );
  } catch (_) {
    return const AuthRequestResult(
      errorMessage: 'Impossible de contacter le serveur',
    );
  } finally {
    client.close();
  }
}

Future<Utilisateur?> request(String login, String pwd) async {
  final result = await loginRequest(login, pwd);
  return result.user;
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
