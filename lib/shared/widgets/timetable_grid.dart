import 'package:flutter/material.dart';
import 'package:follow_me/features/schedule_input/models/timetable_entry.dart';

class TimetableGrid extends StatelessWidget {
  const TimetableGrid({
    super.key,
    required this.entries,
    this.previewEntry,
    this.onEntryTap,
  });

  final List<TimetableEntry> entries;
  final TimetableEntry? previewEntry;
  final void Function(TimetableEntry)? onEntryTap;

  static const _startHour = 7;
  static const _endHour = 23;
  static const _totalHours = _endHour - _startHour;
  static const _timeColWidth = 40.0;
  static const _headerHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        const Divider(height: 0, thickness: 0.5, color: Color(0xFFE0E0E0)),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hourHeight = constraints.maxHeight / _totalHours;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        onEntryTap: onEntryTap,
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
    this.onEntryTap,
  });

  final int dayIndex;
  final List<TimetableEntry> entries;
  final int totalHours;
  final int startHour;
  final double hourHeight;
  final TimetableEntry? previewEntry;
  final void Function(TimetableEntry)? onEntryTap;

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
    final endOffset = entry.endHour - startHour + entry.endMinute / 60.0;

    if (startOffset >= totalHours || endOffset <= 0) return const SizedBox.shrink();
    if (isPreview && endOffset <= startOffset) return const SizedBox.shrink();

    final clampedStart = startOffset.clamp(0.0, totalHours.toDouble());
    final clampedEnd = endOffset.clamp(0.0, totalHours.toDouble());
    final blockHeight =
        ((clampedEnd - clampedStart) * hourHeight - 2).clamp(14.0, double.infinity);

    return Positioned(
      top: clampedStart * hourHeight + 1,
      height: blockHeight,
      left: 2,
      right: 2,
      child: GestureDetector(
        onTap: isPreview ? null : () => onEntryTap?.call(entry),
        child: Container(
          decoration: BoxDecoration(
            color: isPreview
                ? const Color(0x60AAAAAA)
                : Color(entry.colorValue),
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
      ),
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({required this.totalHours, required this.hourHeight});

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
