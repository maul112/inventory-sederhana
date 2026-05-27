import 'inventory_item.dart';

class ClassInventory extends InventoryItem {
  ClassInventory({
    required super.id,
    required super.name,
    required super.quantity,
    required super.condition,
    required super.fundSource,
  }) : super(category: InventoryCategory.classB);

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'condition': condition,
      'fundSource': fundSource,
      'category': category.name,
    };
  }

  factory ClassInventory.fromMap(Map<String, dynamic> map, String id) {
    return ClassInventory(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      condition: map['condition'] ?? 'Layak',
      fundSource: map['fundSource'] ?? 'BOP',
    );
  }
}
