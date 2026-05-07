import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:follow_me/core/constants/app_constants.dart';

class WeatherService {
  static Future<String> getTomorrowWeather() async {
    if (AppConstants.weatherApiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      return '날씨 정보 없음 (API 키 미설정)';
    }
    try {
      final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast'
        '?q=${AppConstants.weatherCity}'
        '&appid=${AppConstants.weatherApiKey}'
        '&lang=${AppConstants.weatherLang}'
        '&units=metric',
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return '날씨 정보를 가져올 수 없습니다.';

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['list'] as List;

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowStr =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      Map<String, dynamic>? best;
      for (final item in list) {
        final dtTxt = item['dt_txt'] as String;
        if (dtTxt.startsWith(tomorrowStr)) {
          best = item as Map<String, dynamic>;
          if (dtTxt.contains('12:00')) break;
        }
      }

      if (best == null) return '내일 날씨 정보 없음';

      final weather = (best['weather'] as List).first;
      final desc = weather['description'] as String;
      final main = best['main'] as Map<String, dynamic>;
      final temp = (main['temp'] as num).round();
      final tempMin = (main['temp_min'] as num).round();
      final tempMax = (main['temp_max'] as num).round();

      return '$desc, 기온 $temp°C (최저 $tempMin°C / 최고 $tempMax°C)';
    } catch (_) {
      return '날씨 정보를 가져올 수 없습니다.';
    }
  }
}
