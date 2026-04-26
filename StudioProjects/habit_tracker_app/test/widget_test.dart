import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/main.dart';

void main() {
  testWidgets('App bootstraps', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitGardenApp());
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
