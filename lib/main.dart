import 'package:flutter/material.dart';
import 'package:follow_me/features/home/screens/home_screen.dart';
import 'package:follow_me/features/onboarding/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
  runApp(MyApp(startWithMain: onboardingDone));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.startWithMain});

  final bool startWithMain;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Follow Me',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF208484)),
        useMaterial3: true,
      ),
      home: startWithMain ? const HomeScreen() : const SignupScreen(),
      // home: const SignupScreen() // 온보딩부터 시작하는 테스트 용
    );
  }
}
