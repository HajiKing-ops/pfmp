import 'dart:convert';

import 'package:appli_pfmp/model/dashboard.dart';
import 'package:http/browser_client.dart';

Future<DashboardStats?> requestDashboardStats() async {
  final client = BrowserClient()..withCredentials = true;

  try {
    final response = await client.get(
      Uri.parse('/api/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardStats.fromJson(decoded);
    }
  } catch (_) {
    return null;
  } finally {
    client.close();
  }

  return null;
}
