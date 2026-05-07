import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:follow_me/core/constants/app_constants.dart';

class GemmaService {
  static Future<String?> generate(String prompt) async {
    try {
      final uri = Uri.parse('${AppConstants.ollamaBaseUrl}/api/generate');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': AppConstants.ollamaModel,
              'prompt': prompt,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['response'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
