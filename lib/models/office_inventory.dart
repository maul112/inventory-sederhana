import 'inventory_item.dart';

class OfficeInventory extends InventoryItem {
  String storeQuantity;   // jumlah di etalase
  String officeNeeds;     // kebutuhan kantor
  String willBePurchased; // yang akan dibeli

  OfficeInventory({
    required super.id,
    required super.name,
    required this.storeQuantity,
    required this.officeNeeds,
    required this.willBePurchased,
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
      'willBePurchased': willBePurchased,
      'category': category.name,
    };
  }

  factory OfficeInventory.fromMap(Map<String, dynamic> map, String id) {
    return OfficeInventory(
      id: id,
      name: map['name'] ?? '',
      storeQuantity: map['storeQuantity']?.toString() ?? '',
      officeNeeds: map['officeNeeds']?.toString() ?? '',
      willBePurchased: map['willBePurchased']?.toString() ?? '',
    );
  }
}
