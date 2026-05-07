class DiaryEntry {
  const DiaryEntry({
    this.id,
    required this.text,
    required this.createdAt,
  });

  final int? id;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'text': text,
        'created_at': createdAt.toIso8601String(),
      };

  static DiaryEntry fromMap(Map<String, dynamic> map) => DiaryEntry(
        id: map['id'] as int?,
        text: map['text'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
