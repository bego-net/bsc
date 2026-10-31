/// Represents a member summary row for the Admin Overview screen.
class MemberOverviewItem {
  final String uid;
  final String name;
  final String email;
  final String? lastReadingDate;
  final bool isPrepared;

  const MemberOverviewItem({
    required this.uid,
    required this.name,
    required this.email,
    this.lastReadingDate,
    required this.isPrepared,
  });
}
