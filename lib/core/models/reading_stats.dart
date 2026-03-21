class ReadingStats {
  final int todayPages;
  final int weekPages;
  final int monthPages;
  final int totalPages;
  final int streak;

  const ReadingStats({
    required this.todayPages,
    required this.weekPages,
    required this.monthPages,
    required this.totalPages,
    required this.streak,
  });

  static const empty = ReadingStats(
    todayPages: 0,
    weekPages: 0,
    monthPages: 0,
    totalPages: 0,
    streak: 0,
  );
}
