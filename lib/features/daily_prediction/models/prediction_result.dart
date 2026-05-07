class PredictionResult {
  const PredictionResult({
    required this.fortune,
    required this.missions,
    required this.date,
  });

  final String fortune;
  final List<String> missions;
  final String date; // YYYY-MM-DD

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
