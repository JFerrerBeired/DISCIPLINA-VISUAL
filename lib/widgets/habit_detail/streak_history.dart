import 'package:flutter/material.dart';

class StreakHistory extends StatelessWidget {
  final List<int> pastStreaks;

  const StreakHistory({
    super.key,
    required this.pastStreaks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Historial de Rachas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: pastStreaks.isEmpty ? 50 : pastStreaks.length * 50.0, // Altura dinámica
          child: pastStreaks.isEmpty
              ? const Center(child: Text('No hay rachas pasadas.'))
              : ListView.builder(
                  itemCount: pastStreaks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Racha: ${pastStreaks[index]} días'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
