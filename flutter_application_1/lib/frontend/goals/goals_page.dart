import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_state.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    int selectedPoints = 10;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'e.g. Save \$200 this week',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: selectedPoints,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('Small (10 XP)')),
                  DropdownMenuItem(value: 25, child: Text('Medium (25 XP)')),
                  DropdownMenuItem(value: 50, child: Text('Big (50 XP)')),
                ],
                onChanged: (v) => setLocal(() => selectedPoints = v ?? 10),
                decoration: const InputDecoration(labelText: 'Goal size'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<GameState>().addGoal(
                      title: titleController.text,
                      points: selectedPoints,
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>(); // ✅ MUST use watch
    final goals = game.goals;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Goals',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddGoalDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // progress summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.local_florist),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Plant Growth: ${(game.growthProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text('${game.completedPoints}/${game.totalPoints} XP'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: goals.isEmpty
                ? const Center(
                    child: Text(
                      'No goals yet.\nTap Add to create your first goal 🌱',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final g = goals[i];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: g.isCompleted,
                            onChanged: (_) =>
                                context.read<GameState>().toggleGoal(g.id),
                          ),
                          title: Text(
                            g.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              decoration: g.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text('${g.points} XP'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                context.read<GameState>().deleteGoal(g.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}