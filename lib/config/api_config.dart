import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? 'https://dorsad-stuart-quarrelsomely.ngrok-free.dev';
  static const String viTriPath = '/api/toanha/vi-tri';
}
