import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:follow_me/core/constants/app_constants.dart';

class GemmaService {
  /// 성공 시 응답 텍스트, 실패 시 null 반환. 에러는 [lastError]에 저장됨.
  static String? lastError;

  static Future<String?> generate(String prompt) async {
    lastError = null;
    try {
      final uri = Uri.parse('${AppConstants.ollamaBaseUrl}/api/generate');
      debugPrint('[Gemma] POST → $uri');

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

      debugPrint('[Gemma] status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['response'] as String?;
        debugPrint('[Gemma] response length: ${result?.length ?? 0}');
        return result;
      } else {
        lastError = 'HTTP ${response.statusCode}: ${response.body}';
        debugPrint('[Gemma] error: $lastError');
      }
    } catch (e) {
      lastError = e.toString();
      debugPrint('[Gemma] exception: $e');
    }
    return null;
  }
}
