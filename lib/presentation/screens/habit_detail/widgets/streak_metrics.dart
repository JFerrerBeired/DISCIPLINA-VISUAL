import 'package:flutter/material.dart';
import 'package:disciplina_visual/domain/usecases/calculate_streak.dart';
import 'package:disciplina_visual/presentation/screens/habit_detail/widgets/metric_card.dart';

class StreakMetrics extends StatelessWidget {
  final Streak? streak;

  const StreakMetrics({super.key, this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MetricCard(
          title: 'Racha Actual',
          value: streak?.current.toString() ?? '0',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        MetricCard(
          title: 'Racha Récord',
          value: streak?.record.toString() ?? '0',
          icon: Icons.star,
          color: Colors.amber,
        ),
      ],
    );
  }
}
