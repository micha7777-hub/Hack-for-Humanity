import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_state.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  @override
  void initState() {
    super.initState();
    // Refresh daily status when opening the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().refreshDailyStatus();
    });
  }

  String _stageLabel(int stage) {
    switch (stage) {
      case 0:
        return 'Seed';
      case 1:
        return 'Sprout';
      case 2:
        return 'Growing';
      case 3:
        return 'Blooming';
      default:
        return 'Flourishing';
    }
  }

  String _stageAsset(int stage) {
    // Make sure these match your asset filenames
    switch (stage) {
      case 0:
        return 'assets/images/plant/seed.png';
      case 1:
        return 'assets/images/plant/sprout.png';
      case 2:
        return 'assets/images/plant/small.png';
      case 3:
        return 'assets/images/plant/medium.png';
      default:
        return 'assets/images/plant/full.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    final stage = game.growthStage;
    final progress = game.growthProgress;

    // gentle scaling effect
    final scale = 0.85 + (0.55 * progress);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Garden',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),

          // Stage image
          AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            child: Image.asset(
              _stageAsset(stage),
              height: 240,
            ),
          ),

          const SizedBox(height: 12),
          Text(
            _stageLabel(stage),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.isNaN ? 0 : progress,
              minHeight: 12,
            ),
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.local_fire_department,
                  title: 'Streak',
                  value: '${game.streakDays} days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  icon: Icons.leaderboard,
                  title: 'Level',
                  value: 'Lv ${game.level}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Water status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    game.wateredToday ? Icons.water_drop : Icons.water_drop_outlined,
                    color: game.wateredToday ? Colors.green : Colors.black45,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      game.wateredToday
                          ? 'Watered today ✅ (you completed at least 1 goal)'
                          : 'Not watered today yet — complete 1 goal to water 🌱',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}