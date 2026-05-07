import 'package:flutter/material.dart';
import 'onboarding_ideal_personality_screen.dart';
import 'personality_test_screen.dart';

class OnboardingMyPersonalityScreen extends StatelessWidget {
  const OnboardingMyPersonalityScreen({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final givenName = userName.length > 1 ? userName.substring(1) : userName;
    return PersonalityTestScreen(
      title: '$givenName님에 대해 알려주세요',
      subtitle: '성향을 분석할게요.',
      accentColor: const Color(0xFF208484),
      cardBgColor: const Color(0xFFE9F7F7),
      onComplete: (scores) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingIdealPersonalityScreen(
            userName: userName,
            myPersonalityScores: scores,
          ),
        ),
      ),
    );
  }
}
