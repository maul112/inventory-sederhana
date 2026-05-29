enum InventoryCategory {
  classB,
  office,
  legger,
}

abstract class InventoryItem {
  String id;
  String name;
  InventoryCategory category;
  String quantity;
  String condition;
  String fundSource;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.condition,
    required this.fundSource,
  });

  Map<String, dynamic> toMap();
}
