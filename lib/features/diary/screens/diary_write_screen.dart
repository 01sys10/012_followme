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
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (_controller.text.trim().isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            '일기 작성 취소',
            style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700),
          ),
          content: const Text(
            '지금까지 쓴 일기가 사라져요.',
            style: TextStyle(fontFamily: 'Pretendard'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('취소', style: TextStyle(color: Color(0xFF6F6F6F))),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('확인', style: TextStyle(color: Color(0xFF208484))),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '일기 쓰기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: 32 / 24,
                          color: Color(0xFF262626),
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleClose,
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: Color(0xFF6F6F6F),
                        ),
                      ),
                    ],
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
