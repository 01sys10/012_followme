import 'package:flutter/material.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/shared/widgets/teal_button.dart';

class SettingsPersonalityResultScreen extends StatelessWidget {
  const SettingsPersonalityResultScreen({
    super.key,
    required this.isIdeal,
    required this.scores,
    required this.onDone,
  });

  final bool isIdeal;
  final List<int> scores;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isIdeal ? const Color(0xFFFEF6DA) : const Color(0xFFE9F7F7);
    final accentColor =
        isIdeal ? const Color(0xFFEEC22A) : const Color(0xFF208484);
    final textColor =
        isIdeal ? const Color(0xFFB8920E) : const Color(0xFF208484);
    final label = isIdeal ? '이상향 성향' : '현재 성향';
    final typeName = isIdeal ? '수호자 성향' : '옹호자 성향';
    final description = isIdeal
        ? '안정적이고 신뢰할 수 있는 수호자 성향을 추구하고 있습니다.'
        : '모험심이 강하고 세상 모든 것에 다정한 옹호자 성향입니다.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 33),
                    // 헤더: 제목 + 닫기 버튼
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          '성향 분석 결과',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            height: 32 / 24,
                            color: Color(0xFF262626),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              size: 24,
                              color: Color(0xFF6F6F6F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 39),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 22 / 15,
                        color: Color(0xFF6F6F6F),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            typeName,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              height: 22 / 16,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 75,
                                height: 72,
                                child: CustomPaint(
                                  painter: _TrianglePainter(accentColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  description,
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    height: 22 / 15,
                                    color: Color(0xFF525252),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isIdeal
                            ? '이상향 성향이 업데이트되었습니다.\n앞으로의 미션이 새로운 이상향에 맞춰 제공돼요.'
                            : '현재 성향이 업데이트되었습니다.\n앞으로의 예측과 미션에 반영될 거예요.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 22 / 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 완료 버튼 (오른쪽 정렬)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TealButton(
                  label: '완료',
                  onTap: () async {
                    if (isIdeal) {
                      await UserDataService.saveIdealScores(scores);
                    } else {
                      await UserDataService.saveMyScores(scores);
                    }
                    onDone();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
