/// Represents a discussion question for a weekly Team Bible Study session.
class Question {
  final String id;
  final String text;
  final int order;
  final bool published;

  const Question({
    required this.id,
    required this.text,
    required this.order,
    this.published = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'order': order,
      'published': published,
    };
  }

  factory Question.fromMap(String id, Map<String, dynamic> map) {
    return Question(
      id: id,
      text: map['text'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
      published: map['published'] as bool? ?? false,
    );
  }

  Question copyWith({
    String? id,
    String? text,
    int? order,
    bool? published,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      order: order ?? this.order,
      published: published ?? this.published,
    );
  }
}
