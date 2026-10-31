import 'ot_day.dart';

/// Represents a weekly Old Testament study plan curated by leaders.
class OtWeek {
  final String id;
  final String topic;
  /// The start date (Monday) in yyyy-MM-dd format.
  final String startDate;
  final DateTime publishedAt;
  final String updatedBy;
  /// Optional loaded days for this week.
  final List<OtDay> days;

  const OtWeek({
    required this.id,
    required this.topic,
    required this.startDate,
    required this.publishedAt,
    this.updatedBy = '',
    this.days = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'startDate': startDate,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory OtWeek.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<OtDay> days = const [],
  }) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return OtWeek(
      id: id,
      topic: map['topic'] as String? ?? '',
      startDate: map['startDate'] as String? ?? '',
      publishedAt: parseDate(map['publishedAt']),
      updatedBy: map['updatedBy'] as String? ?? '',
      days: days,
    );
  }

  OtWeek copyWith({
    String? id,
    String? topic,
    String? startDate,
    DateTime? publishedAt,
    String? updatedBy,
    List<OtDay>? days,
  }) {
    return OtWeek(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      startDate: startDate ?? this.startDate,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      days: days ?? this.days,
    );
  }
}
