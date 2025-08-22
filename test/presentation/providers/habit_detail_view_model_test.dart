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
import 'package:mockito/annotations.dart';

import 'habit_detail_view_model_test.mocks.dart';

@GenerateMocks([
  GetCompletions,
  AddCompletion,
  RemoveCompletion,
  DeleteHabit,
  CalculateStreak,
  DateProvider
])
void main() {
  late MockGetCompletions mockGetCompletions;
  late MockAddCompletion mockAddCompletion;
  late MockRemoveCompletion mockRemoveCompletion;
  late MockDeleteHabit mockDeleteHabit;
  late MockCalculateStreak mockCalculateStreak;
  late MockDateProvider mockDateProvider;
  late HabitDetailViewModel viewModel;

  setUp(() {
    mockGetCompletions = MockGetCompletions();
    mockAddCompletion = MockAddCompletion();
    mockRemoveCompletion = MockRemoveCompletion();
    mockDeleteHabit = MockDeleteHabit();
    mockCalculateStreak = MockCalculateStreak();
    mockDateProvider = MockDateProvider();
    viewModel = HabitDetailViewModel(
      getCompletions: mockGetCompletions,
      addCompletion: mockAddCompletion,
      removeCompletion: mockRemoveCompletion,
      deleteHabit: mockDeleteHabit,
      calculateStreak: mockCalculateStreak,
      dateProvider: mockDateProvider,
    );
  });

  final completions = [
    Completion(id: 1, habitId: 1, date: DateTime.now())
  ];
  final streak = Streak(current: 1, record: 1);
  final today = DateTime.now();

  test('initial state is correct', () {
    expect(viewModel.completions, []);
    expect(viewModel.streak, null);
    expect(viewModel.isLoading, false);
    expect(viewModel.error, null);
  });

  test('loadCompletions success', () async {
    when(mockGetCompletions(any)).thenAnswer((_) async => completions);
    when(mockCalculateStreak(any, any)).thenReturn(streak);
    when(mockDateProvider.simulatedToday).thenReturn(today);

    await viewModel.loadCompletions(1);

    expect(viewModel.completions, completions);
    expect(viewModel.streak, streak);
    expect(viewModel.isLoading, false);
    expect(viewModel.error, null);
  });

  test('addCompletionForHabit calls addCompletion and reloads data', () async {
    when(mockAddCompletion(any, any)).thenAnswer((_) async {});
    when(mockGetCompletions(any)).thenAnswer((_) async => completions);
    when(mockCalculateStreak(any, any)).thenReturn(streak);
    when(mockDateProvider.simulatedToday).thenReturn(today);

    await viewModel.addCompletionForHabit(1, today);

    verify(mockAddCompletion(1, today));
    verify(mockGetCompletions(1));
  });

  test('removeCompletionForHabit calls removeCompletion and reloads data', () async {
    when(mockRemoveCompletion(any, any)).thenAnswer((_) async {});
    when(mockGetCompletions(any)).thenAnswer((_) async => completions);
    when(mockCalculateStreak(any, any)).thenReturn(streak);
    when(mockDateProvider.simulatedToday).thenReturn(today);

    await viewModel.removeCompletionForHabit(1, today);

    verify(mockRemoveCompletion(1, today));
    verify(mockGetCompletions(1));
  });

  test('deleteHabitById calls deleteHabit', () async {
    when(mockDeleteHabit(any)).thenAnswer((_) async => 1);

    await viewModel.deleteHabitById(1);

    verify(mockDeleteHabit(1));
  });
}
