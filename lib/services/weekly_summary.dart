import '../models/member_summary.dart';
import '../models/study_week.dart';

/// Builds a plain-text weekly summary ready to paste into WhatsApp or Telegram.
/// Localized according to [languageCode] ('am' or 'en').
String buildWeeklySummary({
  required StudyWeek? teamWeek,
  required List<MemberSummary> members,
  required String otTopic,
  String languageCode = 'en',
}) {
  final totalMembers = members.length;
  final activeMembers = members.where((m) => m.ibsDaysThisWeek > 0 || m.otDaysThisWeek > 0).length;
  final preparedCount = members.where((m) => m.preparedThisWeek).length;
  final needsEncouragementList = members.where((m) => m.needsEncouragement).map((m) => m.name).toList();

  final buffer = StringBuffer();
  if (languageCode == 'am') {
    buffer.writeln('📖 የሳምንቱ የመጽሐፍ ቅዱስ ጥናት ማጠቃለያ');
    buffer.writeln('');

    if (teamWeek != null) {
      final passage = teamWeek.localizedPassageText(languageCode);
      buffer.writeln('📚 የቡድን ጥናት ምንባብ፡ $passage');
      buffer.writeln('✅ የተዘጋጁ፡ ከ$totalMembers አባላት $preparedCount');
    }

    if (otTopic.isNotEmpty) {
      buffer.writeln('📜 የብሉይ ኪዳን ርዕስ፡ $otTopic');
    }

    buffer.writeln('');
    buffer.writeln('👥 በዚህ ሳምንት ንቁ የሆኑ አባላት፡ ከ$totalMembers $activeMembers');

    if (needsEncouragementList.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('💛 ማበረታቻ የሚያስፈልጋቸው (ለ3+ ቀናት ያላነበቡ)፡');
      for (final name in needsEncouragementList) {
        buffer.writeln('  • $name');
      }
    }
  } else {
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
  }

  return buffer.toString().trim();
}
