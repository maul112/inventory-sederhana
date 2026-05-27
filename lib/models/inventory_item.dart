enum InventoryCategory {
  classB,
  office,
  legger,
}

abstract class InventoryItem {
  String id;
  String name;
  int quantity;
  String condition; // "Layak" or "Rusak"
  String fundSource; // "BOP" or "Sekolah"
  InventoryCategory category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.condition,
    required this.fundSource,
    required this.category,
  });

  Map<String, dynamic> toMap();
}
