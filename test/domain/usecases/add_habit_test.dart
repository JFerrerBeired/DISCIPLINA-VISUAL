import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:disciplina_visual/domain/usecases/add_habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';
import 'package:disciplina_visual/data/models/habit.dart';

import 'add_habit_test.mocks.dart';

@GenerateMocks([HabitRepository])
void main() {
  late AddHabit usecase;
  late MockHabitRepository mockHabitRepository;

  setUp(() {
    mockHabitRepository = MockHabitRepository();
    usecase = AddHabit(mockHabitRepository);
  });

  final tHabit = Habit(id: 1, name: 'Test Habit', color: 1, creationDate: DateTime.now());

  test(
    'should call createHabit on the repository with the correct habit',
    () async {
      // arrange
      when(mockHabitRepository.createHabit(any)).thenAnswer((_) async => 1);
      // act
      await usecase(tHabit);
      // assert
      verify(mockHabitRepository.createHabit(tHabit));
      verifyNoMoreInteractions(mockHabitRepository);
    },
  );
}
