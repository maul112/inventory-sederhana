import 'inventory_item.dart';

class OfficeInventory extends InventoryItem {
  int storeQuantity;   // jumlah di etalase
  int officeNeeds;     // kebutuhan kantor

  // Yang akan dibeli = kebutuhan - etalase (tidak negatif)
  int get willBePurchased => (officeNeeds - storeQuantity).clamp(0, officeNeeds);

  OfficeInventory({
    required super.id,
    required super.name,
    required this.storeQuantity,
    required this.officeNeeds,
  }) : super(
          category: InventoryCategory.office,
          quantity: storeQuantity,
          condition: '',
          fundSource: '',
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'storeQuantity': storeQuantity,
      'officeNeeds': officeNeeds,
      'category': category.name,
    };
  }

  factory OfficeInventory.fromMap(Map<String, dynamic> map, String id) {
    return OfficeInventory(
      id: id,
      name: map['name'] ?? '',
      storeQuantity: map['storeQuantity'] ?? map['remainingQuantity'] ?? 0,
      officeNeeds: map['officeNeeds'] ?? 0,
    );
  }
}
