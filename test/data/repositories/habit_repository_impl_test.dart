import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:disciplina_visual/data/datasources/local/database_helper.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/data/repositories/habit_repository_impl.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';

import 'habit_repository_impl_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late HabitRepository repository;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    repository = HabitRepositoryImpl(databaseHelper: mockDatabaseHelper);
  });

  final tHabit = Habit(id: 1, name: 'Test Habit', color: 1, creationDate: DateTime.now());

  test(
    'should call createHabit on the database helper',
    () async {
      // arrange
      when(mockDatabaseHelper.createHabit(any)).thenAnswer((_) async => 1);
      // act
      await repository.createHabit(tHabit);
      // assert
      verify(mockDatabaseHelper.createHabit(tHabit));
      verifyNoMoreInteractions(mockDatabaseHelper);
    },
  );

  test(
    'should call getAllHabits on the database helper',
    () async {
      // arrange
      when(mockDatabaseHelper.getAllHabits()).thenAnswer((_) async => [tHabit]);
      // act
      await repository.getAllHabits();
      // assert
      verify(mockDatabaseHelper.getAllHabits());
      verifyNoMoreInteractions(mockDatabaseHelper);
    },
  );

  test(
    'should call deleteHabit on the database helper',
    () async {
      // arrange
      when(mockDatabaseHelper.deleteHabit(any)).thenAnswer((_) async => 1);
      // act
      await repository.deleteHabit(tHabit.id!);
      // assert
      verify(mockDatabaseHelper.deleteHabit(tHabit.id!));
      verifyNoMoreInteractions(mockDatabaseHelper);
    },
  );
}
