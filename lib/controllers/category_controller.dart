import 'package:get/get.dart';
import '../models/inventory_item.dart';

class CategoryController extends GetxController {
  Rx<InventoryCategory> selectedCategory = InventoryCategory.classB.obs;

  void setCategory(InventoryCategory category) {
    selectedCategory.value = category;
  }
}
