import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:disciplina_visual/domain/usecases/add_habit.dart';
import 'package:disciplina_visual/domain/usecases/update_habit.dart';
import 'package:disciplina_visual/presentation/providers/create_habit_view_model.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:mockito/annotations.dart';

import 'create_habit_view_model_test.mocks.dart';

@GenerateMocks([AddHabit, UpdateHabit])
void main() {
  late MockAddHabit mockAddHabit;
  late MockUpdateHabit mockUpdateHabit;
  late CreateHabitViewModel viewModel;

  setUp(() {
    mockAddHabit = MockAddHabit();
    mockUpdateHabit = MockUpdateHabit();
    viewModel = CreateHabitViewModel(
      addHabit: mockAddHabit,
      updateHabit: mockUpdateHabit,
    );
  });

  final habit = Habit(id: 1, name: 'Test Habit', color: 0, creationDate: DateTime.now());

  test('initial state is correct', () {
    expect(viewModel.isLoading, false);
    expect(viewModel.error, null);
  });

  test('saveHabit calls addHabit for new habit', () async {
    when(mockAddHabit(any)).thenAnswer((_) async => 1);

    await viewModel.saveHabit(name: 'New Habit', color: 1);

    verify(mockAddHabit(any));
    verifyNever(mockUpdateHabit(any));
  });

  test('saveHabit calls updateHabit for existing habit', () async {
    when(mockUpdateHabit(any)).thenAnswer((_) async => 1);

    await viewModel.saveHabit(habit: habit, name: 'Updated Habit', color: 1);

    verify(mockUpdateHabit(any));
    verifyNever(mockAddHabit(any));
  });

  test('saveHabit handles error', () async {
    final exception = Exception('Failed to save');
    when(mockAddHabit(any)).thenThrow(exception);

    final result = await viewModel.saveHabit(name: 'New Habit', color: 1);

    expect(result, false);
    expect(viewModel.error, exception.toString());
  });
}
