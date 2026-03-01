import 'package:flutter/foundation.dart';
import '../frontend/goals/goal_model.dart';

class GameState extends ChangeNotifier {
  final List<Goal> _goals = [];

  // --- STREAK / WATERING ---
  DateTime? _lastCompletionDay; // date of most recent completed goal day
  int _streakDays = 0;          // consecutive days with >= 1 goal completed
  bool _wateredToday = false;   // did we complete a goal today?

  // --- LEVEL ---
  int _level = 1;
  int _xp = 0;

  List<Goal> get goals => List.unmodifiable(_goals);

  int get streakDays => _streakDays;
  bool get wateredToday => _wateredToday;
  int get level => _level;
  int get xp => _xp;

  // XP goals = sum of completed goal points
  int get completedPoints =>
      _goals.where((g) => g.isCompleted).fold(0, (sum, g) => sum + g.points);

  int get totalPoints => _goals.fold(0, (sum, g) => sum + g.points);

  // Growth progress from completed points + streak bonus
  double get growthProgress {
    if (totalPoints == 0) return 0;

    final base = completedPoints / totalPoints; // 0..1
    final streakBonus = (_streakDays * 0.03).clamp(0.0, 0.15); // up to +15%
    final wateredBonus = _wateredToday ? 0.05 : 0.0; // +5% if watered today

    return (base + streakBonus + wateredBonus).clamp(0.0, 1.0);
  }

  // Stage mapping 0..4
  int get growthStage {
    final p = growthProgress;
    if (p >= 1.0) return 4;
    if (p >= 0.75) return 3;
    if (p >= 0.50) return 2;
    if (p >= 0.25) return 1;
    return 0;
  }

  /// Call this once when app loads OR when opening Garden page.
  /// It checks if a new day has started and resets wateredToday when needed.
  void refreshDailyStatus() {
    final now = _today();
    if (_lastCompletionDay == null) {
      _wateredToday = false;
      notifyListeners();
      return;
    }

    // if last completion was not today, wateredToday should reset
    if (!_isSameDay(_lastCompletionDay!, now)) {
      _wateredToday = false;

      // if we skipped a day, streak breaks (optional strict mode)
      // break streak if last completion day is more than 1 day ago
      if (now.difference(_lastCompletionDay!).inDays > 1) {
        _streakDays = 0;
      }
      notifyListeners();
    }
  }

  void addGoal({required String title, int points = 10}) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    _goals.insert(
      0,
      Goal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: trimmed,
        points: points,
      ),
    );

    notifyListeners();
  }

  void toggleGoal(String id) {
    final i = _goals.indexWhere((g) => g.id == id);
    if (i == -1) return;

    final goal = _goals[i];
    final wasCompleted = goal.isCompleted;

    goal.isCompleted = !goal.isCompleted;

    if (!wasCompleted && goal.isCompleted) {
      // ✅ Completing a goal = water plant + update streak + XP
      _handleGoalCompleted(points: goal.points);
    }

    notifyListeners();
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // -------------------------
  // Internals
  // -------------------------

  void _handleGoalCompleted({required int points}) {
    final today = _today();

    // If first completion ever
    if (_lastCompletionDay == null) {
      _streakDays = 1;
    } else {
      final diffDays = today.difference(_lastCompletionDay!).inDays;

      if (diffDays == 0) {
        // already completed something today -> streak unchanged
      } else if (diffDays == 1) {
        // continued streak
        _streakDays += 1;
      } else {
        // missed days -> reset streak
        _streakDays = 1;
      }
    }

    _lastCompletionDay = today;
    _wateredToday = true;

    // XP system
    _xp += points + 5; // small bonus for completing
    _recalculateLevel();
  }

  void _recalculateLevel() {
    // simple curve: each level needs 100 more xp than the last
    // Level 1: 0-99, Level 2: 100-199, Level 3: 200-299, etc.
    _level = (_xp ~/ 100) + 1;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}