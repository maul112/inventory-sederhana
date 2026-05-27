class Surah {
  final String id;
  final String name;
  final int order;

  Surah({
    required this.id,
    required this.name,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'order': order,
      };

  factory Surah.fromMap(Map<String, dynamic> map, String docId) {
    return Surah(
      id: docId,
      name: map['name'] ?? '',
      order: map['order'] ?? 0,
    );
  }
}
