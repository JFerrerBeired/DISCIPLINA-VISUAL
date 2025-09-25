import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:disciplina_visual/domain/usecases/add_completion.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/domain/usecases/delete_habit.dart';
import 'package:disciplina_visual/domain/usecases/get_completions.dart';
import 'package:disciplina_visual/domain/usecases/remove_completion.dart';
import 'package:disciplina_visual/presentation/providers/habit_detail_view_model.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';
import 'package:disciplina_visual/data/models/completion.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/domain/usecases/calculate_completion_totals_usecase.dart';
import 'package:mockito/annotations.dart';

import 'habit_detail_view_model_test.mocks.dart';

@GenerateMocks([
  GetCompletions,
  AddCompletion,
  RemoveCompletion,
  DeleteHabit,
  CalculateStreak,
  DateProvider,
  CalculateCompletionTotalsUseCase, // Added
])
void main() {
  late MockGetCompletions mockGetCompletions;
  late MockAddCompletion mockAddCompletion;
  late MockRemoveCompletion mockRemoveCompletion;
  late MockDeleteHabit mockDeleteHabit;
  late MockCalculateStreak mockCalculateStreak;
  late MockDateProvider mockDateProvider;
  late MockCalculateCompletionTotalsUseCase
  mockCalculateCompletionTotalsUseCase; // Added
  late HabitDetailViewModel viewModel;

  setUp(() {
    mockGetCompletions = MockGetCompletions();
    mockAddCompletion = MockAddCompletion();
    mockRemoveCompletion = MockRemoveCompletion();
    mockDeleteHabit = MockDeleteHabit();
    mockCalculateStreak = MockCalculateStreak();
    mockDateProvider = MockDateProvider();
    mockCalculateCompletionTotalsUseCase =
        MockCalculateCompletionTotalsUseCase(); // Added
    viewModel = HabitDetailViewModel(
      getCompletions: mockGetCompletions,
      addCompletion: mockAddCompletion,
      removeCompletion: mockRemoveCompletion,
      deleteHabit: mockDeleteHabit,
      calculateStreak: mockCalculateStreak,
      dateProvider: mockDateProvider,
      calculateCompletionTotals: mockCalculateCompletionTotalsUseCase, // Added
    );
  });

  final tHabit = Habit(
    id: 1,
    name: 'Test Habit',
    color: 1,
    creationDate: DateTime(2023, 1, 1),
  ); // Defined a test habit
  final completions = [Completion(id: 1, habitId: 1, date: DateTime.now())];
  final streak = Streak(current: 1, record: 1);
  final today = DateTime.now();

  test('initial state is correct', () {
    expect(viewModel.completions, []);
    expect(viewModel.streak, null);
    expect(viewModel.isLoading, false);
    expect(viewModel.error, null);
    expect(viewModel.chartData, []); // Added check for chartData
    expect(viewModel.habit, null); // Added check for habit
  });

  test('loadCompletions success', () async {
    when(mockGetCompletions(any)).thenAnswer((_) async => completions);
    when(mockCalculateStreak(any, any)).thenReturn(streak);
    when(mockDateProvider.simulatedToday).thenReturn(today);
    when(
      mockCalculateCompletionTotalsUseCase(any),
    ).thenReturn([]); // Mock the use case call

    await viewModel.loadCompletions(1, tHabit); // Updated call

    expect(viewModel.completions, completions);
    expect(viewModel.streak, streak);
    expect(viewModel.isLoading, false);
    expect(viewModel.error, null);
    expect(viewModel.habit, tHabit); // Verify habit is set
    verify(
      mockCalculateCompletionTotalsUseCase(any),
    ).called(1); // Changed to any
  });

  test('addCompletionForHabit calls addCompletion and reloads data', () async {
    when(mockAddCompletion(any, any)).thenAnswer((_) async {});
    when(mockGetCompletions(any)).thenAnswer((_) async => completions);
    when(mockCalculateStreak(any, any)).thenReturn(streak);
    when(mockDateProvider.simulatedToday).thenReturn(today);
    when(
      mockCalculateCompletionTotalsUseCase(any),
    ).thenReturn([]); // Mock the use case call

    await viewModel.loadCompletions(1, tHabit); // Ensure habit is set
    await viewModel.addCompletionForHabit(1, today);

    verify(mockAddCompletion(1, today));
    verify(mockGetCompletions(1));
    verify(mockCalculateCompletionTotalsUseCase(any)).called(
      2,
    ); // Called twice (once by loadCompletions, once by addCompletionForHabit's internal loadCompletions)
  });

  test(
    'removeCompletionForHabit calls removeCompletion and reloads data',
    () async {
      when(mockRemoveCompletion(any, any)).thenAnswer((_) async {});
      when(mockGetCompletions(any)).thenAnswer((_) async => completions);
      when(mockCalculateStreak(any, any)).thenReturn(streak);
      when(mockDateProvider.simulatedToday).thenReturn(today);
      when(
        mockCalculateCompletionTotalsUseCase(any),
      ).thenReturn([]); // Mock the use case call

      await viewModel.loadCompletions(1, tHabit); // Ensure habit is set
      await viewModel.removeCompletionForHabit(1, today);

      verify(mockRemoveCompletion(1, today));
      verify(mockGetCompletions(1));
      verify(
        mockCalculateCompletionTotalsUseCase(any),
      ).called(2); // Called twice
    },
  );

  test('deleteHabitById calls deleteHabit', () async {
    when(mockDeleteHabit(any)).thenAnswer((_) async => 1);

    await viewModel.deleteHabitById(1);

    verify(mockDeleteHabit(1));
  });
}
