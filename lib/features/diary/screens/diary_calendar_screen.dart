import 'package:flutter/material.dart';
import 'package:follow_me/features/diary/data/diary_database.dart';
import 'package:follow_me/features/diary/models/diary_entry.dart';
import 'package:follow_me/features/diary/screens/diary_write_screen.dart';

class DiaryCalendarScreen extends StatefulWidget {
  const DiaryCalendarScreen({super.key});

  @override
  State<DiaryCalendarScreen> createState() => _DiaryCalendarScreenState();
}

class _DiaryCalendarScreenState extends State<DiaryCalendarScreen> {
  late int _year;
  late int _month;
  DateTime? _selectedDate;
  Set<String> _writtenDates = {};

  static const _weekLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadWrittenDates();
  }

  Future<void> _loadWrittenDates() async {
    final dates = await DiaryDatabase.getWrittenDates();
    if (mounted) setState(() => _writtenDates = dates);
  }

  String _dateKey(int year, int month, int day) =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  bool _hasEntry(int day) =>
      _writtenDates.contains(_dateKey(_year, _month, day));

  void _onDateTap(int day) {
    final tapped = DateTime(_year, _month, day);
    setState(() => _selectedDate = tapped);
    if (_hasEntry(day)) _showDiarySheet(tapped);
  }

  Future<void> _showDiarySheet(DateTime date) async {
    final entries = await DiaryDatabase.getByDate(date);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DiaryViewSheet(date: date, entries: entries),
    );
  }

  Future<void> _openWriteScreen() async {
    final date = _selectedDate ?? DateTime.now();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DiaryWriteScreen(date: date)),
    );
    _loadWrittenDates();
  }

  void _prevMonth() => setState(() {
        if (_month == 1) {
          _year--;
          _month = 12;
        } else {
          _month--;
        }
      });

  void _nextMonth() => setState(() {
        if (_month == 12) {
          _year++;
          _month = 1;
        } else {
          _month++;
        }
      });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '일기장',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color(0xFF262626),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedDate != null) ...[
                          GestureDetector(
                            onTap: _openWriteScreen,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9F7F7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '일기쓰기',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF208484),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Color(0xFF6F6F6F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 월 네비게이션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.chevron_left,
                        color: Color(0xFF6F6F6F), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_year년 $_month월',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _nextMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.chevron_right,
                        color: Color(0xFF6F6F6F), size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 요일 헤더 (일 ~ 토)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _weekLabels.map((label) {
                  final isWeekend = label == '일' || label == '토';
                  return Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isWeekend
                              ? const Color(0xFFD94C4C)
                              : const Color(0xFF6F6F6F),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // 캘린더 그리드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildGrid(now),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(DateTime now) {
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    // Dart weekday: 1=월 ~ 7=일 → 열 인덱스(0=일 기준): weekday % 7
    final startOffset = firstDay.weekday % 7;

    final cells = <Widget>[];

    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final col = (startOffset + day - 1) % 7;
      final isSunCol = col == 0;
      final isSatCol = col == 6;
      final isToday = now.year == _year && now.month == _month && now.day == day;
      final isSelected = _selectedDate?.year == _year &&
          _selectedDate?.month == _month &&
          _selectedDate?.day == day;
      final hasEntry = _hasEntry(day);

      cells.add(
        GestureDetector(
          onTap: () => _onDateTap(day),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: isSelected
                    ? const BoxDecoration(
                        color: Color(0xFF208484),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 15,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF208484)
                              : isSunCol || isSatCol
                                  ? const Color(0xFFD94C4C)
                                  : const Color(0xFF262626),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasEntry
                      ? (isSelected ? Colors.white : const Color(0xFF208484))
                      : Colors.transparent,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      );
    }

    // 7개씩 Row로 묶기
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final slice = cells.sublist(i, (i + 7).clamp(0, cells.length));
      while (slice.length < 7) {
        slice.add(const SizedBox());
      }
      rows.add(Row(
        children: slice.map((c) => Expanded(child: c)).toList(),
      ));
    }

    return Column(children: rows);
  }
}

// ── 일기 내용 보기 바텀 시트 ──────────────────────────────────────────────

class _DiaryViewSheet extends StatelessWidget {
  const _DiaryViewSheet({required this.date, required this.entries});

  final DateTime date;
  final List<DiaryEntry> entries;

  static const _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

  String get _dateLabel =>
      '${date.year}년 ${date.month}월 ${date.day}일 (${_weekdayNames[date.weekday - 1]})';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _dateLabel,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF262626),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < entries.length; i++) ...[
                    if (i > 0) ...[
                      const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    ],
                    Text(
                      entries[i].text,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 24 / 15,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
