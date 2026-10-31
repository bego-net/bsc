/// Holds member completion data for the current Old Testament week.
class OtMemberOverviewItem {
  final String uid;
  final String name;
  final String email;
  final int completedDays;
  final int totalDays;

  const OtMemberOverviewItem({
    required this.uid,
    required this.name,
    required this.email,
    required this.completedDays,
    required this.totalDays,
  });

  /// Formatted string like "Selam T.: 4 of 5" or "4 of 5".
  String get displayProgress => '$completedDays of $totalDays';
}
