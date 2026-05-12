import 'package:flutter/material.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/features/home/screens/home_screen.dart';
import 'package:follow_me/features/schedule_input/models/timetable_entry.dart';
import 'package:follow_me/shared/widgets/entry_form_sheet.dart';
import 'package:follow_me/shared/widgets/next_button.dart';
import 'package:follow_me/shared/widgets/timetable_grid.dart';
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
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: EntryFormSheet(
          existingEntries: _entries,
          onPreviewChange: (e) => setState(() => _previewEntry = e),
          onSave: (e) => setState(() => _entries.add(e)),
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
          },
        ),
      ),
    ).then((_) {
      setState(() {
        if (!saved) _entries.add(entry);
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
    }
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
              child: TimetableGrid(
                entries: _entries,
                previewEntry: _previewEntry,
                onEntryTap: _onEntryTap,
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
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
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
