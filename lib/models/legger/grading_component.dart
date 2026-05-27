/// type: 'tahsin' | 'tahfiz'
class GradingComponent {
  final String id;
  final String name;
  final String type; // 'tahsin' atau 'tahfiz'
  final int order;

  GradingComponent({
    required this.id,
    required this.name,
    required this.type,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'order': order,
      };

  factory GradingComponent.fromMap(Map<String, dynamic> map, String docId) {
    return GradingComponent(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'tahsin',
      order: map['order'] ?? 0,
    );
  }
}
