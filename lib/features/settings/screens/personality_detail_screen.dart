import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:follow_me/core/utils/personality_type_utils.dart';
import 'package:follow_me/features/settings/screens/personality_all_screen.dart';
import 'package:follow_me/shared/widgets/floating_tab_bar.dart';

class PersonalityDetailScreen extends StatelessWidget {
  const PersonalityDetailScreen({
    super.key,
    required this.isIdeal,
    required this.scores,
    this.gender,
    this.customTitle,
    this.showAllButton = true,
  });

  final bool isIdeal;
  final List<int> scores;
  final String? gender;
  final String? customTitle;
  final bool showAllButton;

  @override
  Widget build(BuildContext context) {
    final color =
        isIdeal ? const Color(0xFFEEC22A) : const Color(0xFF208484);
    final title = customTitle ?? (isIdeal ? '현재 이상향' : '현재 내 성향');
    final personality = classifyPersonality(scores, gender: gender);
    final typeName = scores.isEmpty ? 'OO 성향' : personality.name;
    final description = scores.isEmpty
        ? '성향 분석을 완료하면 그래프가 업데이트돼요.'
        : personality.description;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingTabBar(
            selectedIndex: 2,
            onTap: (i) {
              if (i == 2) {
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/settings' || route.isFirst,
                );
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
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
                    // 성향 이름
                    Text(
                      typeName,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 성향 설명
                    Text(
                      scores.isEmpty
                          ? '성향 분석을 완료하면 그래프가 업데이트돼요.'
                          : description,
                      style: const TextStyle(
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
                        height: 210,
                        child: CustomPaint(
                          painter: _HexagonPainter(
                            color: color,
                            scores: scores,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showAllButton) ...[
              const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  const _HexagonPainter({
    required this.color,
    required this.scores,
  });

  final Color color;
  final List<int> scores;

  static const _labels = ['모험적', '사색적', '외향적', '주도적', '다정함', '논리적'];
  static const _sides = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxRadius = size.width * 0.30;
    final labelRadius = size.width * 0.44;
    final degToRad = math.pi / 180;

    // 배경 육각형
    final bgPoints = <Offset>[
      for (int i = 0; i < _sides; i++)
        Offset(
          cx + maxRadius * math.cos((i * 60 - 90) * degToRad),
          cy + maxRadius * math.sin((i * 60 - 90) * degToRad),
        ),
    ];
    final bgPath = Path()..moveTo(bgPoints[0].dx, bgPoints[0].dy);
    for (int i = 1; i < _sides; i++) { bgPath.lineTo(bgPoints[i].dx, bgPoints[i].dy); }
    bgPath.close();

    canvas.drawPath(bgPath,
        Paint()..color = color.withValues(alpha: 0.1)..style = PaintingStyle.fill);
    canvas.drawPath(bgPath,
        Paint()..color = color.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 1);

    // 데이터 다각형
    final dataPoints = <Offset>[
      for (int i = 0; i < _sides; i++)
        Offset(
          cx + maxRadius * ((i < scores.length ? scores[i] : 0) / 25).clamp(0.0, 1.0) * math.cos((i * 60 - 90) * degToRad),
          cy + maxRadius * ((i < scores.length ? scores[i] : 0) / 25).clamp(0.0, 1.0) * math.sin((i * 60 - 90) * degToRad),
        ),
    ];
    final dataPath = Path()..moveTo(dataPoints[0].dx, dataPoints[0].dy);
    for (int i = 1; i < _sides; i++) { dataPath.lineTo(dataPoints[i].dx, dataPoints[i].dy); }
    dataPath.close();

    canvas.drawPath(dataPath,
        Paint()..color = color.withValues(alpha: 0.3)..style = PaintingStyle.fill);
    canvas.drawPath(dataPath,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset(cx, cy), 4,
        Paint()..color = color..style = PaintingStyle.fill);

    // 라벨
    for (int i = 0; i < _sides; i++) {
      final angle = (i * 60 - 90) * degToRad;
      final lx = cx + labelRadius * math.cos(angle);
      final ly = cy + labelRadius * math.sin(angle);

      final painter = TextPainter(
        text: TextSpan(
          text: _labels[i],
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(lx - painter.width / 2, ly - painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_HexagonPainter old) =>
      old.color != color || old.scores != scores;
}
