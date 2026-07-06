import 'dart:convert';

import 'package:appli_pfmp/model/profile.dart';
import 'package:http/browser_client.dart';

const _profileReadEndpoints = [
  '/api/profile/me',
  '/api/profile',
  '/api/etudiants/me/profile',
];

const _profileUpdateEndpoints = [
  '/api/profile/me',
  '/api/etudiants/me/profile',
];

class ProfileApiResult {
  final StudentProfile? profile;
  final String? errorMessage;

  const ProfileApiResult({this.profile, this.errorMessage});

  bool get success => profile != null;
}

Future<ProfileApiResult> requestProfileMe() async {
  final client = BrowserClient()..withCredentials = true;

  try {
    for (final endpoint in _profileReadEndpoints) {
      final response = await client.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileApiResult(profile: StudentProfile.fromJson(decoded));
      }

      if (response.statusCode != 404) {
        return ProfileApiResult(
          errorMessage: _responseMessage(
            response.statusCode,
            response.body,
            fallback: 'Impossible de charger le profil',
          ),
        );
      }
    }

    return const ProfileApiResult(
      errorMessage:
          'Endpoint profil introuvable: GET /api/profile/me, GET /api/profile ou GET /api/etudiants/me/profile',
    );
  } catch (_) {
    return const ProfileApiResult(
      errorMessage: 'Impossible de contacter le serveur',
    );
  } finally {
    client.close();
  }
}

Future<ProfileApiResult> updateProfileMe(StudentProfile profile) async {
  final client = BrowserClient()..withCredentials = true;
  final body = jsonEncode(profile.toUpdateJson());

  try {
    for (final endpoint in _profileUpdateEndpoints) {
      final response = await client.put(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileApiResult(profile: StudentProfile.fromJson(decoded));
      }

      if (response.statusCode == 204) {
        return ProfileApiResult(profile: profile);
      }

      if (response.statusCode != 404) {
        return ProfileApiResult(
          errorMessage: _responseMessage(
            response.statusCode,
            response.body,
            fallback: 'Impossible de mettre a jour le profil',
          ),
        );
      }
    }

    return const ProfileApiResult(
      errorMessage:
          'Endpoint profil introuvable: PUT /api/profile/me ou PUT /api/etudiants/me/profile',
    );
  } catch (_) {
    return const ProfileApiResult(
      errorMessage: 'Impossible de contacter le serveur',
    );
  } finally {
    client.close();
  }
}

String _responseMessage(
  int statusCode,
  String body, {
  required String fallback,
}) {
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
