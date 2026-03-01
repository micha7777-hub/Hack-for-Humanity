class Goal {
  final String id;
  final String title;
  final int points; // how much it grows the plant
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    this.points = 10,
    this.isCompleted = false,
  });
}