import 'package:flutter/material.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/features/main/screens/main_screen.dart';
import 'package:follow_me/features/schedule_input/models/timetable_entry.dart';
import 'package:follow_me/shared/widgets/next_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingTimetableScreen extends StatefulWidget {
  const OnboardingTimetableScreen({super.key, required this.userName});

  final String userName;

  @override
  State<OnboardingTimetableScreen> createState() =>
      _OnboardingTimetableScreenState();
}

class _OnboardingTimetableScreenState
    extends State<OnboardingTimetableScreen> {
  final List<TimetableEntry> _entries = [];
  TimetableEntry? _previewEntry;

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _AddEntrySheet(
          existingEntries: _entries,
          onPreviewChange: (entry) => setState(() => _previewEntry = entry),
          onAdd: (entry) => setState(() => _entries.add(entry)),
        ),
      ),
    ).then((_) => setState(() => _previewEntry = null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 33),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '고정 일정을 알려주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 32 / 24,
                  color: Color(0xFF262626),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '일주일 시간표를 만들어주세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 22 / 15,
                  color: Color(0xFF6F6F6F),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _TimetableView(
                entries: _entries,
                previewEntry: _previewEntry,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _showAddSheet,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 40,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF1A1A1A),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NextButton(
                onTap: () async {
                  await UserDataService.saveTimetable(_entries);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_complete', true);
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (_) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── 주간 타임테이블 그리드 ──────────────────────────────────────────────────

class _TimetableView extends StatelessWidget {
  const _TimetableView({required this.entries, this.previewEntry});

  final List<TimetableEntry> entries;
  final TimetableEntry? previewEntry;

  static const _startHour = 7;
  static const _endHour = 23;
  static const _totalHours = _endHour - _startHour;
  static const _timeColWidth = 40.0;
  static const _headerHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 요일 헤더
        Row(
          children: [
            const SizedBox(width: _timeColWidth),
            ...List.generate(7, (i) {
              final isWeekend = i >= 5;
              return Expanded(
                child: SizedBox(
                  height: _headerHeight,
                  child: Center(
                    child: Text(
                      TimetableEntry.dayLabels[i],
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
                ),
              );
            }),
          ],
        ),
        // 구분선
        const Divider(height: 0, thickness: 0.5, color: Color(0xFFE0E0E0)),
        // 그리드 (LayoutBuilder로 화면에 꽉 채움, 스크롤 없음)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hourHeight = constraints.maxHeight / _totalHours;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 시간 레이블 열
                  SizedBox(
                    width: _timeColWidth,
                    child: Stack(
                      children: List.generate(_totalHours, (i) {
                        return Positioned(
                          top: i * hourHeight - 7,
                          left: 0,
                          right: 0,
                          child: Text(
                            (_startHour + i).toString().padLeft(2, '0'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8D8D8D),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // 요일 열 × 7
                  ...List.generate(
                    7,
                    (dayIndex) => Expanded(
                      child: _DayColumn(
                        dayIndex: dayIndex,
                        entries: entries
                            .where((e) => e.dayIndex == dayIndex)
                            .toList(),
                        totalHours: _totalHours,
                        startHour: _startHour,
                        hourHeight: hourHeight,
                        previewEntry: previewEntry?.dayIndex == dayIndex
                            ? previewEntry
                            : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.dayIndex,
    required this.entries,
    required this.totalHours,
    required this.startHour,
    required this.hourHeight,
    this.previewEntry,
  });

  final int dayIndex;
  final List<TimetableEntry> entries;
  final int totalHours;
  final int startHour;
  final double hourHeight;
  final TimetableEntry? previewEntry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GridLinePainter(
              totalHours: totalHours,
              hourHeight: hourHeight,
            ),
          ),
        ),
        if (previewEntry != null) _buildBlock(previewEntry!, isPreview: true),
        for (final entry in entries) _buildBlock(entry),
      ],
    );
  }

  Widget _buildBlock(TimetableEntry entry, {bool isPreview = false}) {
    final startOffset =
        entry.startHour - startHour + entry.startMinute / 60.0;
    final endOffset =
        entry.endHour - startHour + entry.endMinute / 60.0;

    if (startOffset >= totalHours || endOffset <= 0) {
      return const SizedBox.shrink();
    }
    if (isPreview && endOffset <= startOffset) {
      return const SizedBox.shrink();
    }

    final clampedStart = startOffset.clamp(0.0, totalHours.toDouble());
    final clampedEnd = endOffset.clamp(0.0, totalHours.toDouble());
    final blockHeight =
        ((clampedEnd - clampedStart) * hourHeight - 2)
            .clamp(14.0, double.infinity);

    return Positioned(
      top: clampedStart * hourHeight + 1,
      height: blockHeight,
      left: 2,
      right: 2,
      child: Container(
        decoration: BoxDecoration(
          color: isPreview
              ? const Color(0x60AAAAAA)
              : const Color(0xD9208484),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: isPreview
            ? null
            : Text(
                entry.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
      ),
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({
    required this.totalHours,
    required this.hourHeight,
  });

  final int totalHours;
  final double hourHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 0.5;

    final borderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.5;

    canvas.drawLine(Offset.zero, Offset(0, size.height), borderPaint);

    for (int i = 0; i <= totalHours; i++) {
      final y = i * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter old) =>
      old.totalHours != totalHours || old.hourHeight != hourHeight;
}

// ── 일정 추가 바텀 시트 ────────────────────────────────────────────────────

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({
    required this.onAdd,
    required this.existingEntries,
    required this.onPreviewChange,
  });

  final void Function(TimetableEntry) onAdd;
  final List<TimetableEntry> existingEntries;
  final void Function(TimetableEntry?) onPreviewChange;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _nameCtrl = TextEditingController();
  int _selectedDay = 0;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  static const _fieldBg = Color(0xFFE9F7F7);
  static const _labelStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 22 / 15,
    color: Color(0xFF6F6F6F),
  );
  static const _fieldTextStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Color(0xFF222222),
  );

  @override
  void initState() {
    super.initState();
    // 시트가 열리는 즉시 기본 시간 위치에 회색 미리보기 표시
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyPreview());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _notifyPreview() {
    widget.onPreviewChange(TimetableEntry(
      name: _nameCtrl.text.trim(),
      dayIndex: _selectedDay,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
    ));
  }

  bool get _isValid {
    final startMin = _startTime.hour * 60 + _startTime.minute;
    final endMin = _endTime.hour * 60 + _endTime.minute;
    return _nameCtrl.text.trim().isNotEmpty && endMin > startMin;
  }

  bool _hasOverlap() {
    final newStart = _startTime.hour * 60 + _startTime.minute;
    final newEnd = _endTime.hour * 60 + _endTime.minute;
    for (final e in widget.existingEntries) {
      if (e.dayIndex != _selectedDay) continue;
      final eStart = e.startHour * 60 + e.startMinute;
      final eEnd = e.endHour * 60 + e.endMinute;
      if (newStart < eEnd && newEnd > eStart) return true;
    }
    return false;
  }

  void _submit() {
    if (!_isValid) return;
    if (_hasOverlap()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('일정 겹침'),
          content: const Text('해당 시간대에 이미 등록된 일정이 있습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }
    widget.onAdd(TimetableEntry(
      name: _nameCtrl.text.trim(),
      dayIndex: _selectedDay,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
    ));
    Navigator.of(context).pop();
  }

  Future<void> _pickTime() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: '시작 시간',
    );
    if (start == null) return;
    if (!mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: '종료 시간',
    );
    if (end == null) return;
    setState(() {
      _startTime = start;
      _endTime = end;
    });
    _notifyPreview();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grabber
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x14787880),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF727272),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '고정 일정 추가',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x14007AFF),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 18,
                        color: _isValid
                            ? const Color(0xFF0088FF)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 0.5),
            // 폼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('일정 이름', style: _labelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    style: _fieldTextStyle,
                    decoration: InputDecoration(
                      hintText: '수업',
                      hintStyle: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF8D8D8D),
                      ),
                      filled: true,
                      fillColor: _fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Text('요일', style: _labelStyle),
                      SizedBox(width: 126),
                      Text('시간', style: _labelStyle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 요일 드롭다운
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _fieldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedDay,
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF222222),
                              size: 18,
                            ),
                            style: _fieldTextStyle,
                            items: List.generate(
                              7,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(TimetableEntry.dayFullLabels[i]),
                              ),
                            ),
                            onChanged: (v) {
                              setState(() => _selectedDay = v!);
                              _notifyPreview();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 시간 필드
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _fieldBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_fmt(_startTime)}   -   ${_fmt(_endTime)}',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
