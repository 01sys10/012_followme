import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:follow_me/features/settings/screens/personality_detail_screen.dart';
import 'package:follow_me/shared/widgets/floating_tab_bar.dart';

// 각 성향의 대표 점수: 주축 22 → 인접 13 → 8 → 반대 5 → 8 → 13 패턴 순환
const _representativeScores = [
  [22, 13, 8, 5, 8, 13], // 앨리스형  — 모험적
  [13, 22, 13, 8, 5, 8], // 어린왕자형 — 사색적
  [8, 13, 22, 13, 8, 5], // 피터팬형  — 외향적
  [5, 8, 13, 22, 13, 8], // 빨간모자형 — 주도적
  [8, 5, 8, 13, 22, 13], // 백설공주형 — 다정함
  [13, 8, 5, 8, 13, 22], // 도로시형  — 논리적
];

const _names = [
  '앨리스형',
  '어린왕자형',
  '피터팬형',
  '빨간모자형',
  '백설공주형',
  '도로시형',
];

class PersonalityAllScreen extends StatelessWidget {
  const PersonalityAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          children: [
            const SizedBox(height: 16),
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
                  const Text(
                    '전체 성향',
                    style: TextStyle(
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 6,
                  itemBuilder: (ctx, index) => GestureDetector(
                    onTap: () => Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => PersonalityDetailScreen(
                          isIdeal: false,
                          scores: List<int>.from(_representativeScores[index]),
                          customTitle: _names[index],
                        ),
                      ),
                    ),
                    child: _PersonalityGridCard(index: index),
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

class _PersonalityGridCard extends StatelessWidget {
  const _PersonalityGridCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _names[index],
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF262626),
            ),
          ),
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(60, 55),
                painter: _MiniRadarPainter(
                  scores: List<int>.from(_representativeScores[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRadarPainter extends CustomPainter {
  const _MiniRadarPainter({required this.scores});

  final List<int> scores;

  static const _color = Color(0xFF208484);
  static const _count = 6;
  static const _maxScore = 22.0;
  static const _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.9;

    // 배경 육각형
    final bgPath = _buildPath(List.filled(_count, 22), r, cx, cy);
    canvas.drawPath(
      bgPath,
      Paint()
        ..color = _color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      bgPath,
      Paint()
        ..color = _color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 데이터 다각형
    final dataPath = _buildPath(scores, r, cx, cy);
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = _color.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = _color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  Path _buildPath(List<int> s, double r, double cx, double cy) {
    final path = Path();
    for (int i = 0; i < _count; i++) {
      final angle = _startAngle + 2 * math.pi * i / _count;
      final ratio = (s[i] / _maxScore).clamp(0.0, 1.0);
      final pt = Offset(cx + r * ratio * math.cos(angle),
          cy + r * ratio * math.sin(angle));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_MiniRadarPainter old) => old.scores != scores;
}
