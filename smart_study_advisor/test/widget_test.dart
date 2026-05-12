// Basic Flutter widget test for Smart Study Advisor.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_study_advisor/main.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartStudyAdvisorApp());

    // Verify that the app title is shown.
    expect(find.text('Smart Study Advisor'), findsWidgets);
  });
}
