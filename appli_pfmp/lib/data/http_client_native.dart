import 'package:http/http.dart' as http;

/// Returns a fresh native client owned by the caller.
http.Client createHttpClient() => http.Client();
