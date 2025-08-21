import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:disciplina_visual/models/completion.dart';
import 'package:disciplina_visual/screens/habit_detail_screen.dart';

void main() {
  group('getChartData', () {
    test('calculates weekly completion percentages correctly', () {
      // 1. Arrange
      final simulatedToday = DateTime(2024, 3, 15); // A Friday

      // Mock completions data
      final completions = [
        // Week 0 (Mar 9 - Mar 15): 3 completions out of 7 days = 42.85%
        Completion(habitId: 1, date: DateTime(2024, 3, 15)), // Fri
        Completion(habitId: 1, date: DateTime(2024, 3, 13)), // Wed
        Completion(habitId: 1, date: DateTime(2024, 3, 11)), // Mon

        // Week 1 (Mar 2 - Mar 8): 7 completions out of 7 days = 100%
        Completion(habitId: 1, date: DateTime(2024, 3, 8)),
        Completion(habitId: 1, date: DateTime(2024, 3, 7)),
        Completion(habitId: 1, date: DateTime(2024, 3, 6)),
        Completion(habitId: 1, date: DateTime(2024, 3, 5)),
        Completion(habitId: 1, date: DateTime(2024, 3, 4)),
        Completion(habitId: 1, date: DateTime(2024, 3, 3)),
        Completion(habitId: 1, date: DateTime(2024, 3, 2)),

        // Week 2 (Feb 24 - Mar 1): 0 completions

        // Week 3 (Feb 17 - Feb 23): 1 completion out of 7 days = 14.28%
        Completion(habitId: 1, date: DateTime(2024, 2, 20)),
      ];

      // 2. Act
      final chartData = getChartData(completions, simulatedToday);

      // 3. Assert
      // The function calculates for the last 8 weeks.
      // Weeks with no data will still be present in the totalDaysInWeek map.
      // The weeks are sorted by weekIndex, so week 0 is first.
      expect(chartData.length, 8); // Should have data for 8 weeks

      // Check percentages. We use closeTo for floating point comparisons.
      // Week 0: 3/7 * 100 = 42.857...
      expect(chartData[0].y, closeTo(42.85, 0.01));

      // Week 1: 7/7 * 100 = 100.0
      expect(chartData[1].y, closeTo(100.0, 0.01));

      // Week 2: 0/7 * 100 = 0.0
      expect(chartData[2].y, closeTo(0.0, 0.01));

      // Week 3: 1/7 * 100 = 14.285...
      expect(chartData[3].y, closeTo(14.28, 0.01));

      // The rest of the weeks should be 0%
      for (int i = 4; i < 8; i++) {
        expect(chartData[i].y, closeTo(0.0, 0.01));
      }
    });
  });
}
