import 'package:flutter/material.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/features/diary/screens/diary_calendar_screen.dart';
import 'package:follow_me/features/schedule_input/models/timetable_entry.dart';
import 'package:follow_me/features/settings/screens/settings_tab_screen.dart';
import 'package:follow_me/shared/widgets/entry_form_sheet.dart';
import 'package:follow_me/shared/widgets/floating_tab_bar.dart';
import 'package:follow_me/shared/widgets/timetable_grid.dart';

class ScheduleTabScreen extends StatefulWidget {
  const ScheduleTabScreen({super.key});

  @override
  State<ScheduleTabScreen> createState() => _ScheduleTabScreenState();
}

class _ScheduleTabScreenState extends State<ScheduleTabScreen> {
  List<TimetableEntry> _entries = [];
  TimetableEntry? _previewEntry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await UserDataService.getTimetable();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() => UserDataService.saveTimetable(_entries);

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: EntryFormSheet(
          existingEntries: _entries,
          onPreviewChange: (e) => setState(() => _previewEntry = e),
          onSave: (e) {
            setState(() => _entries.add(e));
            _save();
          },
        ),
      ),
    ).then((_) => setState(() => _previewEntry = null));
  }

  void _onEntryTap(TimetableEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditSheet(entry);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFFD94C4C),
              ),
              title: const Text(
                '삭제',
                style: TextStyle(color: Color(0xFFD94C4C)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(TimetableEntry entry) {
    // 수정 중인 항목을 목록에서 임시 제거해 미리보기만 표시
    setState(() => _entries.remove(entry));
    bool saved = false;
    final others = List<TimetableEntry>.from(_entries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: EntryFormSheet(
          initialEntry: entry,
          existingEntries: others,
          onPreviewChange: (e) => setState(() => _previewEntry = e),
          onSave: (updated) {
            saved = true;
            setState(() => _entries.add(updated));
            _save();
          },
        ),
      ),
    ).then((_) {
      setState(() {
        if (!saved) _entries.add(entry); // 취소 시 원래 항목 복원
        _previewEntry = null;
      });
    });
  }

  Future<void> _confirmDelete(TimetableEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '일정 삭제',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          '일정이 삭제됩니다.',
          style: TextStyle(fontFamily: 'Pretendard'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF6F6F6F)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Color(0xFFD94C4C)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _entries.remove(entry));
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingTabBar(
            selectedIndex: 0,
            onTap: (i) {
              if (i == 2) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondary) =>
                        const SettingsTabScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              } else if (i != 0) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 33),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '주간 일정',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 32 / 24,
                      color: Color(0xFF262626),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DiaryCalendarScreen(),
                          ),
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F7F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.book_outlined,
                            color: Color(0xFF208484),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showAddSheet,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F7F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF208484),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF208484),
                      ),
                    )
                  : TimetableGrid(
                      entries: _entries,
                      previewEntry: _previewEntry,
                      onEntryTap: _onEntryTap,
                    ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
