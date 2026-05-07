import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:follow_me/features/schedule_input/models/timetable_entry.dart';

class UserDataService {
  static const _keyName = 'user_name';
  static const _keyBirthdate = 'user_birthdate';
  static const _keyGender = 'user_gender';
  static const _keyMyScores = 'my_personality_scores';
  static const _keyIdealScores = 'ideal_personality_scores';
  static const _keyTimetable = 'timetable_entries';

  static Future<void> saveProfile({
    required String name,
    required DateTime birthdate,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyBirthdate, birthdate.toIso8601String());
    await prefs.setString(_keyGender, gender);
  }

  static Future<void> savePersonalityScores({
    required List<int> myScores,
    required List<int> idealScores,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMyScores, jsonEncode(myScores));
    await prefs.setString(_keyIdealScores, jsonEncode(idealScores));
  }

  static Future<void> saveTimetable(List<TimetableEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = entries.map((e) => e.toMap()).toList();
    await prefs.setString(_keyTimetable, jsonEncode(data));
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<DateTime?> getBirthdate() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyBirthdate);
    return s != null ? DateTime.tryParse(s) : null;
  }

  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGender);
  }

  static Future<List<int>> getMyScores() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyMyScores);
    if (s == null) return [];
    return (jsonDecode(s) as List).cast<int>();
  }

  static Future<List<int>> getIdealScores() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyIdealScores);
    if (s == null) return [];
    return (jsonDecode(s) as List).cast<int>();
  }

  static Future<List<TimetableEntry>> getTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyTimetable);
    if (s == null) return [];
    final list = jsonDecode(s) as List;
    return list
        .map((e) => TimetableEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
