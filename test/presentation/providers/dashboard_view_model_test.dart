import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:disciplina_visual/domain/usecases/get_all_habits.dart';
import 'package:disciplina_visual/presentation/providers/dashboard_view_model.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:mockito/annotations.dart';

import 'dashboard_view_model_test.mocks.dart';

@GenerateMocks([GetAllHabits])
void main() {
  late MockGetAllHabits mockGetAllHabits;
  late DashboardViewModel viewModel;

  setUp(() {
    mockGetAllHabits = MockGetAllHabits();
    viewModel = DashboardViewModel(getAllHabits: mockGetAllHabits);
  });

  test('initial state is correct', () {
    expect(viewModel.habits, []);
    expect(viewModel.isLoading, false);
    expect(viewModel.error, null);
  });

  test('loadHabits success', () async {
    final habits = [
      Habit(id: 1, name: 'Test Habit', color: 0, creationDate: DateTime.now()),
    ];
    when(mockGetAllHabits.call()).thenAnswer((_) async => habits);

    final states = <bool>[];
    viewModel.addListener(() {
      states.add(viewModel.isLoading);
    });

    await viewModel.loadHabits();

    expect(states, [true, false]);
    expect(viewModel.habits, habits);
    expect(viewModel.error, null);
  });

  test('loadHabits error', () async {
    final exception = Exception('Failed to load habits');
    when(mockGetAllHabits.call()).thenThrow(exception);

    final states = <bool>[];
    viewModel.addListener(() {
      states.add(viewModel.isLoading);
    });

    await viewModel.loadHabits();

    expect(states, [true, false]);
    expect(viewModel.habits, []);
    expect(viewModel.error, exception.toString());
  });
}
