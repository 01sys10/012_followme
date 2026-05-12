import 'package:flutter/material.dart';
import 'package:follow_me/features/onboarding/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Follow Me',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF208484)),
        useMaterial3: true,
      ),
      home: const SignupScreen(),
    );
  }
}
