import 'dart:convert';

import 'package:appli_pfmp/model/message.dart';
import 'package:http/browser_client.dart';

class MessageApiResult<T> {
  final T? data;
  final String? errorMessage;

  const MessageApiResult({this.data, this.errorMessage});

  bool get success => errorMessage == null;
}

Future<MessageApiResult<List<MessagePfmp>>> fetchMessages(int idPfmp) async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final response = await client.get(
      Uri.parse('/api/messages/$idPfmp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      return MessageApiResult(
        data: body
            .map((e) => MessagePfmp.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    return MessageApiResult(
      errorMessage: _responseMessage(
        response.body,
        fallback: 'Impossible de charger les messages',
      ),
    );
  } catch (_) {
    return const MessageApiResult(
      errorMessage: 'Impossible de contacter le serveur',
    );
  } finally {
    client.close();
  }
}

Future<MessageApiResult<MessagePfmp>> sendMessage(
  int idPfmp,
  String contenu,
) async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final response = await client.post(
      Uri.parse('/api/messages/$idPfmp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'contenu': contenu}),
    );

    if (response.statusCode == 200) {
      return MessageApiResult(
        data: MessagePfmp.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        ),
      );
    }

    return MessageApiResult(
      errorMessage: _responseMessage(
        response.body,
        fallback: "Impossible d'envoyer le message",
      ),
    );
  } catch (_) {
    return const MessageApiResult(
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
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'] ?? decoded['title'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
  } catch (_) {
    return body;
  }

  return fallback;
}
