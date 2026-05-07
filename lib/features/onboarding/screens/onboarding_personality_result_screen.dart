import 'package:flutter/material.dart';
import 'package:follow_me/core/services/user_data_service.dart';
import 'package:follow_me/features/schedule_input/screens/onboarding_timetable_screen.dart';
import 'package:follow_me/shared/widgets/next_button.dart';

class OnboardingPersonalityResultScreen extends StatelessWidget {
  const OnboardingPersonalityResultScreen({
    super.key,
    required this.userName,
    required this.myPersonalityScores,
    required this.idealPersonalityScores,
  });

  final String userName;
  final List<int> myPersonalityScores;
  final List<int> idealPersonalityScores;

  static const _bgColor = Color(0xFFFFFFFF);
  static const _titleColor = Color(0xFF262626);
  static const _labelColor = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    // TODO: 점수 기반 성향 분류 로직 추가 후 아래 placeholder 교체
    const myTypeName = '옹호자 성향';
    const myTypeDesc = '모험심이 강하고 세상 모든 것에 다정한 옹호자 성향입니다.';
    const idealTypeName = '수호자 성향';
    const idealTypeDesc = '안정적이고 신뢰할 수 있는 수호자 성향을 추구하고 있습니다.';

    return Scaffold(
      backgroundColor: _bgColor,
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
                    const Text(
                      '성향 분석 결과',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 32 / 24,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 39),
                    const Text(
                      '현재 성향',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 22 / 15,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PersonalityCard(
                      bgColor: const Color(0xFFE9F7F7),
                      accentColor: const Color(0xFF208484),
                      typeName: myTypeName,
                      description: myTypeDesc,
                    ),
                    const SizedBox(height: 49),
                    const Text(
                      '이상향 성향',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 22 / 15,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PersonalityCard(
                      bgColor: const Color(0xFFFEF6DA),
                      accentColor: const Color(0xFFEEC22A),
                      typeName: idealTypeName,
                      description: idealTypeDesc,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NextButton(
                onTap: () async {
                  await UserDataService.savePersonalityScores(
                    myScores: myPersonalityScores,
                    idealScores: idealPersonalityScores,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnboardingTimetableScreen(
                        userName: userName,
                      ),
                    ),
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

class _PersonalityCard extends StatelessWidget {
  const _PersonalityCard({
    required this.bgColor,
    required this.accentColor,
    required this.typeName,
    required this.description,
  });

  final Color bgColor;
  final Color accentColor;
  final String typeName;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
