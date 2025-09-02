import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:disciplina_visual/domain/usecases/delete_habit.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

import 'delete_habit_test.mocks.dart';

@GenerateMocks([HabitRepository])
void main() {
  late DeleteHabit usecase;
  late MockHabitRepository mockHabitRepository;

  setUp(() {
    mockHabitRepository = MockHabitRepository();
    usecase = DeleteHabit(mockHabitRepository);
  });

  const tHabitId = 1;

  test(
    'should call deleteHabit on the repository with the correct id',
    () async {
      // arrange
      when(mockHabitRepository.deleteHabit(any)).thenAnswer((_) async => 1);
      // act
      await usecase(tHabitId);
      // assert
      verify(mockHabitRepository.deleteHabit(tHabitId));
      verifyNoMoreInteractions(mockHabitRepository);
    },
  );
}
