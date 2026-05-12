// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:follow_me/main.dart';

void main() {
  testWidgets('Onboarding screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the onboarding screen is displayed
    expect(find.text('회원가입'), findsOneWidget);
    expect(find.text('이름'), findsOneWidget);
    expect(find.text('생년월일'), findsOneWidget);
    expect(find.text('성별'), findsOneWidget);
  });
}
