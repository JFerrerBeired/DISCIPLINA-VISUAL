import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/habit.dart';
import '../../models/completion.dart';

class Heatmap extends StatefulWidget {
  final Habit habit;
  final List<Completion> completions;
  final ScrollController scrollController;
  final DateTime simulatedToday;
  final Future<void> Function(DateTime date, bool isCurrentlyCompleted) onCellTap;
  final VoidCallback onEditModeToggled;

  const Heatmap({
    super.key,
    required this.habit,
    required this.completions,
    required this.scrollController,
    required this.simulatedToday,
    required this.onCellTap,
    required this.onEditModeToggled,
  });

  @override
  State<Heatmap> createState() => _HeatmapState();
}

class _HeatmapState extends State<Heatmap> {
  bool _isEditingHeatmap = false;

  @override
  Widget build(BuildContext context) {
    final List<String> weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final List<List<DateTime?>> weeksData = [];

    DateTime startDate = widget.habit.creationDate;
    DateTime endDate = widget.simulatedToday;

    startDate = startDate.subtract(Duration(days: startDate.weekday - 1));

    List<DateTime?> currentWeek = List.filled(7, null);

    for (DateTime d = startDate; d.isBefore(endDate.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Actividad Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(_isEditingHeatmap ? Icons.check : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditingHeatmap = !_isEditingHeatmap;
                });
                if (!_isEditingHeatmap) {
                  widget.onEditModeToggled();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 310.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 35),
                  ...weekdays.map((dayName) => Container(
                    height: 35,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(2.0),
                    child: Text(dayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )).toList(),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: weeksData.length,
                  itemBuilder: (context, weekIndex) {
                    final week = weeksData[weekIndex];
                    final firstDayOfThisWeek = week.firstWhere((day) => day != null, orElse: () => null);
                    String monthIndicator = '';
                    if (firstDayOfThisWeek != null) {
                      if (weekIndex == 0) {
                        monthIndicator = DateFormat('MMM').format(firstDayOfThisWeek);
                      } else {
                        final previousWeek = weeksData[weekIndex - 1];
                        final lastDayOfPreviousWeek = previousWeek.lastWhere((day) => day != null, orElse: () => null);
                        bool foundNewMonthFirstDay = false;
                        for (DateTime? dayInCurrentWeek in week) {
                          if (dayInCurrentWeek != null && dayInCurrentWeek.day == 1) {
                            if (lastDayOfPreviousWeek != null && dayInCurrentWeek.month != lastDayOfPreviousWeek.month) {
                              monthIndicator = DateFormat('MMM').format(dayInCurrentWeek);
                              foundNewMonthFirstDay = true;
                              break;
                            }
                          }
                        }
                        if (!foundNewMonthFirstDay && lastDayOfPreviousWeek != null && firstDayOfThisWeek.month != lastDayOfPreviousWeek.month) {
                          monthIndicator = DateFormat('MMM').format(firstDayOfThisWeek);
                        }
                      }
                    }

                    return Column(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          alignment: Alignment.center,
                          child: Text(monthIndicator, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                        ...week.map((day) {
                          final isCompleted = day != null && widget.completions.any(
                            (c) => c.date.year == day.year &&
                                   c.date.month == day.month &&
                                   c.date.day == day.day,
                          );
                          return GestureDetector(
                            onTap: day == null || !_isEditingHeatmap
                                ? null
                                : () => widget.onCellTap(day, isCompleted),
                            child: Container(
                              width: 35,
                              height: 35,
                              margin: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: day == null ? Colors.transparent : (isCompleted ? Color(widget.habit.color) : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: day == null ? null : Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: isCompleted ? Colors.white : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
