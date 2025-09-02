import 'package:flutter_test/flutter_test.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/data/models/completion.dart';

void main() {
  late CalculateStreak calculateStreak;

  setUp(() {
    calculateStreak = CalculateStreak();
  });

  group('CalculateStreak Use Case', () {
    final today = DateTime(2023, 10, 27);
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));

    // Helper to create completions
    Completion comp(DateTime date) => Completion(id: 1, habitId: 1, date: date);

    group('Current Streak', () {
      test('should be 0 for empty completions', () {
        final streak = calculateStreak.call([], today);
        expect(streak.current, 0);
      });

      test('should be 0 if not completed today or yesterday', () {
        final completions = [comp(dayBeforeYesterday)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.current, 0);
      });

      test('should be 1 if only completed today', () {
        final completions = [comp(today)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.current, 1);
      });

      test('should be 2 for a two-day streak ending today', () {
        final completions = [comp(today), comp(yesterday)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.current, 2);
      });

      test('should be 3 for a three-day streak ending today', () {
        final completions = [comp(today), comp(yesterday), comp(dayBeforeYesterday)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.current, 3);
      });

      test('should count streak ending yesterday if today is not completed', () {
        final completions = [comp(yesterday), comp(dayBeforeYesterday)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.current, 2);
      });

      test('should ignore duplicate completions on the same day', () {
        final completions = [comp(today), comp(today), comp(yesterday)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.current, 2);
      });
    });

    group('Record Streak', () {
      test('should be 0 for empty completions', () {
        final streak = calculateStreak.call([], today);
        expect(streak.record, 0);
      });

      test('should be 1 for a single completion', () {
        final completions = [comp(today)];
        final streak = calculateStreak.call(completions, today);
        expect(streak.record, 1);
      });

      test('should find the longest streak among multiple streaks', () {
        final completions = [
          // Streak 1 (length 2)
          comp(today.subtract(const Duration(days: 5))),
          comp(today.subtract(const Duration(days: 6))),
          // Streak 2 (length 3)
          comp(today.subtract(const Duration(days: 1))),
          comp(today.subtract(const Duration(days: 2))),
          comp(today.subtract(const Duration(days: 3))),
        ];
        final streak = calculateStreak.call(completions, today);
        expect(streak.record, 3);
      });

      test('should handle a single long streak', () {
        final completions = List.generate(10, (i) => comp(today.subtract(Duration(days: i))));
        final streak = calculateStreak.call(completions, today);
        expect(streak.record, 10);
      });

      test('should handle unordered completions', () {
        final completions = [
          comp(today.subtract(const Duration(days: 2))),
          comp(today),
          comp(today.subtract(const Duration(days: 1))),
        ];
        final streak = calculateStreak.call(completions, today);
        expect(streak.record, 3);
      });

      test('should ignore duplicate completions for record calculation', () {
        final completions = [
          comp(today),
          comp(today),
          comp(yesterday),
          comp(yesterday),
        ];
        final streak = calculateStreak.call(completions, today);
        expect(streak.record, 2);
      });
    });
  });
}
