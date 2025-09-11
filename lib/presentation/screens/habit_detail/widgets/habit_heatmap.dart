import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disciplina_visual/data/models/habit.dart';
import 'package:disciplina_visual/data/models/completion.dart';

class HabitHeatmap extends StatelessWidget {
  final Habit habit;
  final List<Completion> completions;
  final DateTime simulatedToday;
  final bool isEditing;
  final Function(DateTime, bool) onCellTap;
  final ScrollController scrollController;

  const HabitHeatmap({
    super.key,
    required this.habit,
    required this.completions,
    required this.simulatedToday,
    required this.isEditing,
    required this.onCellTap,
    required this.scrollController,
  });

  List<List<DateTime?>> _calculateWeeksData() {
    final List<List<DateTime?>> weeksData = [];
    DateTime startDate = habit.creationDate;
    DateTime endDate = simulatedToday;
    startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
    List<DateTime?> currentWeek = List.filled(7, null);

    for (DateTime d = startDate;
        d.isBefore(endDate.add(const Duration(days: 1)));
        d = d.add(const Duration(days: 1))) {
      int weekdayIndex = (d.weekday - 1 + 7) % 7;
      currentWeek[weekdayIndex] = d;

      if (weekdayIndex == 6) {
        weeksData.add(currentWeek);
        currentWeek = List.filled(7, null);
      }
    }
    if (currentWeek.any((element) => element != null)) {
      weeksData.add(currentWeek);
    }
    return weeksData;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final List<List<DateTime?>> weeksData = _calculateWeeksData();

    return SizedBox(
      height: 310.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 35),
              ...weekdays
                  .map((dayName) => Container(
                        height: 35,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(2.0),
                        child: Text(dayName,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      )),
            ],
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: weeksData.length,
              itemBuilder: (context, weekIndex) {
                final week = weeksData[weekIndex];
                final firstDayOfThisWeek = week.firstWhere(
                    (day) => day != null,
                    orElse: () => null);
                String monthIndicator = '';
                if (firstDayOfThisWeek != null) {
                  if (weekIndex == 0) {
                    monthIndicator =
                        DateFormat('MMM').format(firstDayOfThisWeek);
                  } else {
                    final previousWeek = weeksData[weekIndex - 1];
                    final lastDayOfPreviousWeek =
                        previousWeek.lastWhere((day) => day != null,
                            orElse: () => null);
                    bool foundNewMonthFirstDay = false;
                    for (DateTime? dayInCurrentWeek in week) {
                      if (dayInCurrentWeek != null &&
                          dayInCurrentWeek.day == 1) {
                        if (lastDayOfPreviousWeek != null &&
                            dayInCurrentWeek.month !=
                                lastDayOfPreviousWeek.month) {
                          monthIndicator = DateFormat('MMM')
                              .format(dayInCurrentWeek);
                          foundNewMonthFirstDay = true;
                          break;
                        }
                      }
                    }
                    if (!foundNewMonthFirstDay &&
                        lastDayOfPreviousWeek != null &&
                        firstDayOfThisWeek.month !=
                            lastDayOfPreviousWeek.month) {
                      monthIndicator = DateFormat('MMM')
                          .format(firstDayOfThisWeek);
                    }
                  }
                }
                return Column(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      child: Text(monthIndicator,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ),
                    ...week.map((day) {
                      final isCompleted = day != null &&
                          completions.any((c) =>
                              c.date.year == day.year &&
                              c.date.month == day.month &&
                              c.date.day == day.day);
                      return GestureDetector(
                        onTap: day == null || !isEditing
                            ? null
                            : () => onCellTap(day, isCompleted),
                        child: Container(
                          width: 35,
                          height: 35,
                          margin: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: day == null
                                ? Colors.transparent
                                : (isCompleted
                                    ? Color(habit.color)
                                    : Colors.grey.shade200),
                            borderRadius:
                                BorderRadius.circular(4.0),
                          ),
                          child: day == null
                              ? null
                              : Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
