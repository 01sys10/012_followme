import 'dart:math';

import 'package:flutter/material.dart';
import 'package:follow_me/features/schedule_input/models/timetable_entry.dart';

const _entryColors = [0xD9208484, 0xD9EEC22A];

class EntryFormSheet extends StatefulWidget {
  const EntryFormSheet({
    super.key,
    required this.existingEntries,
    required this.onPreviewChange,
    required this.onSave,
    this.initialEntry,
  });

  /// null이면 추가 모드, non-null이면 수정 모드
  final TimetableEntry? initialEntry;
  final List<TimetableEntry> existingEntries;
  final void Function(TimetableEntry?) onPreviewChange;
  final void Function(TimetableEntry) onSave;

  @override
  State<EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends State<EntryFormSheet> {
  late final TextEditingController _nameCtrl;
  late int _selectedDay;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

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
    final e = widget.initialEntry;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _selectedDay = e?.dayIndex ?? 0;
    _startTime = e != null
        ? TimeOfDay(hour: e.startHour, minute: e.startMinute)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = e != null
        ? TimeOfDay(hour: e.endHour, minute: e.endMinute)
        : const TimeOfDay(hour: 10, minute: 0);
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
    final colorValue = widget.initialEntry?.colorValue
        ?? _entryColors[Random().nextInt(_entryColors.length)];
    widget.onSave(TimetableEntry(
      name: _nameCtrl.text.trim(),
      dayIndex: _selectedDay,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      endHour: _endTime.hour,
      endMinute: _endTime.minute,
      colorValue: colorValue,
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
    final isEditMode = widget.initialEntry != null;
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
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                  Expanded(
                    child: Text(
                      isEditMode ? '고정 일정 수정' : '고정 일정 추가',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('일정 이름', style: _labelStyle),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: (_) {
                      setState(() {});
                      _notifyPreview();
                    },
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
