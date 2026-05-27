import 'inventory_item.dart';

class InventoryRecord {
  final String id;
  final String title;
  final InventoryCategory category;
  final DateTime createdAt;

  InventoryRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InventoryRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return InventoryRecord(
      id: documentId,
      title: map['title'] ?? '',
      category: InventoryCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => InventoryCategory.classB,
      ),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
