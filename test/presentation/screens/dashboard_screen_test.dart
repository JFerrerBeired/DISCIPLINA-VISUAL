import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:disciplina_visual/presentation/providers/dashboard_view_model.dart';
import 'package:disciplina_visual/presentation/screens/dashboard_screen.dart';
import 'package:disciplina_visual/presentation/utils/date_provider.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:mockito/annotations.dart';
import 'package:disciplina_visual/domain/repositories/habit_repository.dart';
import 'dashboard_screen_test.mocks.dart';

@GenerateMocks([DashboardViewModel, DateProvider, HabitRepository])
void main() {
  late MockDashboardViewModel mockDashboardViewModel;
  late MockDateProvider mockDateProvider;
  late MockHabitRepository mockHabitRepository;

  setUp(() {
    mockDashboardViewModel = MockDashboardViewModel();
    mockDateProvider = MockDateProvider();
    mockHabitRepository = MockHabitRepository();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardViewModel>.value(
          value: mockDashboardViewModel,
        ),
        ChangeNotifierProvider<DateProvider>.value(value: mockDateProvider),
        Provider<HabitRepository>.value(value: mockHabitRepository),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    );
  }

  final habits = [
    Habit(id: 1, name: 'Test Habit', color: 0, creationDate: DateTime.now()),
  ];

  testWidgets('shows loading indicator when loading', (tester) async {
    when(mockDashboardViewModel.isLoading).thenReturn(true);
    when(mockDashboardViewModel.habits).thenReturn([]);
    when(mockDashboardViewModel.error).thenReturn(null);
    when(mockDateProvider.simulatedToday).thenReturn(DateTime.now());
    when(mockDateProvider.dayOffset).thenReturn(0);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows list of habits when loaded', (tester) async {
    when(mockDashboardViewModel.isLoading).thenReturn(false);
    when(mockDashboardViewModel.habits).thenReturn(habits);
    when(mockDashboardViewModel.error).thenReturn(null);
    when(mockDateProvider.simulatedToday).thenReturn(DateTime.now());
    when(mockDateProvider.dayOffset).thenReturn(0);
    when(
      mockHabitRepository.getCompletionsForHabit(any),
    ).thenAnswer((_) async => []);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Test Habit'), findsOneWidget);
  });

  testWidgets('shows error message on error', (tester) async {
    when(mockDashboardViewModel.isLoading).thenReturn(false);
    when(mockDashboardViewModel.habits).thenReturn([]);
    when(mockDashboardViewModel.error).thenReturn('Failed to load');
    when(mockDateProvider.simulatedToday).thenReturn(DateTime.now());
    when(mockDateProvider.dayOffset).thenReturn(0);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Error: Failed to load'), findsOneWidget);
  });
}
