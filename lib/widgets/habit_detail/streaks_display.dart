import 'package:flutter/material.dart';
import 'package:disciplina_visual/widgets/habit_detail/metric_card.dart';

class StreaksDisplay extends StatelessWidget {
  final int currentStreak;
  final int recordStreak;

  const StreaksDisplay({
    super.key,
    required this.currentStreak,
    required this.recordStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MetricCard(
          title: 'Racha Actual',
          value: currentStreak.toString(),
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        MetricCard(
          title: 'Racha Récord',
          value: recordStreak.toString(),
          icon: Icons.star,
          color: Colors.amber,
        ),
      ],
    );
  }
}
