import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/models/habit.dart';

void main() {
  test('Habit growth stages are mapped correctly', () {
    expect(Habit(id: '1', title: 'A', category: 'Health', level: 1).stageLabel, 'Seed');
    expect(Habit(id: '2', title: 'B', category: 'Health', level: 2).stageLabel, 'Sprout');
    expect(Habit(id: '3', title: 'C', category: 'Health', level: 3).stageLabel, 'Flower');
    expect(Habit(id: '4', title: 'D', category: 'Health', level: 4).stageLabel, 'Tree');
  });
}
