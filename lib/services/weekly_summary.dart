import '../models/member_summary.dart';
import '../models/study_week.dart';

/// Builds a plain-text weekly summary ready to paste into WhatsApp or Telegram.
String buildWeeklySummary({
  required StudyWeek? teamWeek,
  required List<MemberSummary> members,
  required String otTopic,
}) {
  final totalMembers = members.length;
  final activeMembers = members.where((m) => m.ibsDaysThisWeek > 0 || m.otDaysThisWeek > 0).length;
  final preparedCount = members.where((m) => m.preparedThisWeek).length;
  final needsEncouragementList = members.where((m) => m.needsEncouragement).map((m) => m.name).toList();

  final buffer = StringBuffer();
  buffer.writeln('📖 Weekly Bible Study Summary');
  buffer.writeln('');

  if (teamWeek != null) {
    buffer.writeln('📚 Team BS passage: ${teamWeek.passageText}');
    buffer.writeln('✅ Prepared: $preparedCount of $totalMembers');
  }

  if (otTopic.isNotEmpty) {
    buffer.writeln('📜 OT topic: $otTopic');
  }

  buffer.writeln('');
  buffer.writeln('👥 Active members this week: $activeMembers of $totalMembers');

  if (needsEncouragementList.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('💛 Needs encouragement (3+ days without reading):');
    for (final name in needsEncouragementList) {
      buffer.writeln('  • $name');
    }
  }

  return buffer.toString().trim();
}
