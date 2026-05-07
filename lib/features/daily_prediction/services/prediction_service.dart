import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:follow_me/core/services/gemma_service.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/core/services/weather_service.dart';
import 'package:follow_me/features/daily_prediction/models/prediction_result.dart';
import 'package:follow_me/features/diary/data/diary_database.dart';

class PredictionService {
  static const _keyDate = 'prediction_date';
  static const _keyFortune = 'prediction_fortune';
  static const _keyMissions = 'prediction_missions';

  static Future<PredictionResult?> getToday() async {
    final prefs = await SharedPreferences.getInstance();
    final fortune = prefs.getString(_keyFortune);
    final missionsJson = prefs.getString(_keyMissions);
    if (fortune == null || missionsJson == null) return null;
    final missions = (jsonDecode(missionsJson) as List).cast<String>();
    return PredictionResult(
      fortune: fortune,
      missions: missions,
      date: prefs.getString(_keyDate) ?? '',
    );
  }

  static Future<void> generateAndSave() async {
    final prompt = await _buildPrompt();
    final raw = await GemmaService.generate(prompt);
    final result = _parse(raw);
    await _save(result);
  }

  static Future<String> _buildPrompt() async {
    final birthdate = await UserDataService.getBirthdate();
    final gender = await UserDataService.getGender();
    final myScores = await UserDataService.getMyScores();
    final idealScores = await UserDataService.getIdealScores();
    final timetable = await UserDataService.getTimetable();
    final weather = await WeatherService.getTomorrowWeather();

    final allDiaries = await DiaryDatabase.getAll();
    final today = PredictionResult.todayKey();
    final todayDiary = allDiaries
        .where((d) => d.createdAt.toIso8601String().startsWith(today))
        .toList();

    final birthdateStr = birthdate != null
        ? '${birthdate.year}년 ${birthdate.month}월 ${birthdate.day}일'
        : '정보 없음';
    final genderStr =
        gender == 'M' ? '남성' : (gender == 'F' ? '여성' : '정보 없음');

    final scheduleStr = timetable.isEmpty
        ? '등록된 고정 일정 없음'
        : timetable
            .map((e) => '${e.dayLabel}요일 ${e.timeLabel} ${e.name}')
            .join('\n');

    final myAvg = myScores.isEmpty
        ? '-'
        : (myScores.reduce((a, b) => a + b) / myScores.length)
            .toStringAsFixed(1);
    final idealAvg = idealScores.isEmpty
        ? '-'
        : (idealScores.reduce((a, b) => a + b) / idealScores.length)
            .toStringAsFixed(1);

    final diarySection = todayDiary.isEmpty
        ? ''
        : '\n오늘의 일기:\n${todayDiary.first.text}';

    return '''아래 정보를 바탕으로 내일의 운세와 미션을 한국어로 생성하세요.

사용자 정보:
- 생년월일: $birthdateStr
- 성별: $genderStr
- 현재 성향 점수 평균 (1-5점): $myAvg
- 이상향 성향 점수 평균 (1-5점): $idealAvg

내일 날씨: $weather

주간 고정 일정:
$scheduleStr$diarySection

반드시 아래 JSON 형식만 출력하세요 (다른 설명 없이):
{"fortune":"운세를 2~3문장으로 작성","missions":["미션1","미션2","미션3","미션4"]}''';
  }

  static PredictionResult _parse(String? raw) {
    if (raw != null) {
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
        if (jsonMatch != null) {
          final data =
              jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
          final fortune = data['fortune'] as String? ?? '';
          final rawMissions = data['missions'];
          List<String> missions = [];
          if (rawMissions is List) {
            missions = rawMissions.map((e) => e.toString()).toList();
          }
          if (fortune.isNotEmpty && missions.length == 4) {
            return PredictionResult(
              fortune: fortune,
              missions: missions,
              date: PredictionResult.todayKey(),
            );
          }
        }
      } catch (_) {}
    }
    return PredictionResult(
      fortune: '오늘도 차분하게 하루를 시작해보세요. 작은 것에 집중하다 보면 큰 흐름이 만들어집니다.',
      missions: ['물 8잔 마시기', '10분 산책하기', '감사한 일 3가지 적기', '일찍 자기'],
      date: PredictionResult.todayKey(),
    );
  }

  static Future<void> _save(PredictionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDate, result.date);
    await prefs.setString(_keyFortune, result.fortune);
    await prefs.setString(_keyMissions, jsonEncode(result.missions));
  }
}
