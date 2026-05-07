import 'package:flutter/material.dart';
import 'package:follow_me/features/diary/data/diary_database.dart';
import 'package:follow_me/features/diary/models/diary_entry.dart';
import 'package:follow_me/shared/widgets/teal_button.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final _controller = TextEditingController();
  int _selectedTab = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _keyboardOpen => MediaQuery.viewInsetsOf(context).bottom > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 33),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '일기 쓰기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 32 / 24,
                      color: Color(0xFF262626),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '자세히 쓸 수록 앞으로 제공되는 운세의 정확도가 높아져요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 22 / 14,
                      color: Color(0xFF6F6F6F),
                    ),
                  ),
                ),
                const SizedBox(height: 33),
                // 일기 입력 영역
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 24 / 14,
                          color: Color(0xFF222222),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '오늘 하루를 기록해보세요.',
                          hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 24 / 14,
                            color: Color(0xFF8D8D8D),
                          ),
                        ),
                      ),
                    ),
                ),
                const SizedBox(height: 24),
                // 완료 버튼
                Center(
                  child: TealButton(
                    label: '완료',
                    onTap: () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      // TODO: 비식별화 처리 후 저장
                      await DiaryDatabase.insert(
                        DiaryEntry(text: text, createdAt: DateTime.now()),
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(height: _keyboardOpen ? 16 : 100),
              ],
            ),
          ),
          // 플로팅 탭바 (키보드 닫혔을 때만 표시)
          if (!_keyboardOpen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTabBar(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      (icon: Icons.calendar_month, label: '주간 일정'),
      (icon: Icons.task_alt, label: '미션'),
      (icon: Icons.settings, label: '설정'),
    ];

    return Center(
      child: Container(
        width: 302,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(296),
          color: const Color(0xFFF7F7F7),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 40,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(3, (i) {
            final selected = i == _selectedTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 62,
                  decoration: selected
                      ? BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(100),
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[i].icon,
                        size: 18,
                        color: selected
                            ? const Color(0xFF208484)
                            : const Color(0xFF1A1A1A),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tabs[i].label,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          height: 12 / 10,
                          color: selected
                              ? const Color(0xFF208484)
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
