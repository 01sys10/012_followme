class TimetableEntry {
  const TimetableEntry({
    required this.name,
    required this.dayIndex,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.colorValue = 0xD9208484,
  });

  final String name;
  final int dayIndex; // 0=월 1=화 2=수 3=목 4=금 5=토 6=일
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int colorValue;

  static const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  static const dayFullLabels = [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일'
  ];

  String get dayLabel => dayLabels[dayIndex];

  String get timeLabel {
    final s =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final e =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    return '$s - $e';
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'dayIndex': dayIndex,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'colorValue': colorValue,
      };

  factory TimetableEntry.fromMap(Map<String, dynamic> map) => TimetableEntry(
        name: map['name'] as String,
        dayIndex: map['dayIndex'] as int,
        startHour: map['startHour'] as int,
        startMinute: map['startMinute'] as int,
        endHour: map['endHour'] as int,
        endMinute: map['endMinute'] as int,
        colorValue: (map['colorValue'] as int?) ?? 0xD9208484,
      );
}
