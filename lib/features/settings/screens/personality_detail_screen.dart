import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:follow_me/features/settings/screens/personality_all_screen.dart';
import 'package:follow_me/shared/widgets/floating_tab_bar.dart';

class PersonalityDetailScreen extends StatelessWidget {
  const PersonalityDetailScreen({super.key, required this.isIdeal});

  final bool isIdeal;

  @override
  Widget build(BuildContext context) {
    final color =
        isIdeal ? const Color(0xFFEEC22A) : const Color(0xFF208484);
    final title = isIdeal ? '현재 이상향' : '현재 내 성향';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingTabBar(
            selectedIndex: 2,
            onTap: (i) {
              if (i != 2) Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 28,
                        color: Color(0xFF262626),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF262626),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 성향 카드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 24,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 성향 이름 (나중에 채워질 자리)
                    const Text(
                      'OO 성향',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 성향 설명 (나중에 채워질 자리)
                    const Text(
                      '',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFF6F6F6F),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 도형 자리
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 185,
                        child: CustomPaint(
                          painter: _HexagonPainter(color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 다른 성향 보기 버튼
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PersonalityAllScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '다른 성향 보기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 3 * i - math.pi / 6;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexagonPainter old) => old.color != color;
}
