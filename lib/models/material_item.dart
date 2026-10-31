/// Represents study material or a reading reference for a weekly session.
class MaterialItem {
  final String id;
  final String title;
  final String body;
  final String? url;
  final bool published;

  const MaterialItem({
    required this.id,
    required this.title,
    this.body = '',
    this.url,
    this.published = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'url': url,
      'published': published,
    };
  }

  factory MaterialItem.fromMap(String id, Map<String, dynamic> map) {
    return MaterialItem(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      url: map['url'] as String?,
      published: map['published'] as bool? ?? false,
    );
  }

  MaterialItem copyWith({
    String? id,
    String? title,
    String? body,
    String? url,
    bool? published,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      url: url ?? this.url,
      published: published ?? this.published,
    );
  }
}
