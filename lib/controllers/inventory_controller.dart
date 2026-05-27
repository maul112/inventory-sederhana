import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/inventory_item.dart';
import '../models/inventory_record.dart';
import '../models/class_inventory.dart';
import '../models/office_inventory.dart';
import 'auth_controller.dart';

class InventoryController extends GetxController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  RxList<InventoryRecord> records = <InventoryRecord>[].obs;
  RxList<InventoryItem> items = <InventoryItem>[].obs;
  Rx<InventoryRecord?> selectedRecord = Rx<InventoryRecord?>(null);
  
  @override
  void onReady() {
    super.onReady();
    ever(AuthController.instance.userRx, (_) {
      bindRecordsStream();
    });
    bindRecordsStream();
  }

  void bindRecordsStream() {
    final userId = AuthController.instance.user?.uid;
    if (userId == null) {
      records.clear();
      return;
    }

    final DatabaseReference ref = _database.ref('records').child(userId);

    records.bindStream(ref.onValue.map((event) {
      final List<InventoryRecord> loadedRecords = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> dataMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        dataMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          loadedRecords.add(InventoryRecord.fromMap(data, key.toString()));
        });
        loadedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return loadedRecords;
    }));
  }

  void selectRecord(InventoryRecord record) {
    selectedRecord.value = record;
    if (record.category != InventoryCategory.legger) {
      bindItemsStream(record.id);
    }
  }

  void bindItemsStream(String recordId) {
    final userId = AuthController.instance.user?.uid;
    if (userId == null) return;
    
    final category = selectedRecord.value!.category;
    final DatabaseReference ref =
        _database.ref('items').child(userId).child(recordId);

    items.bindStream(ref.onValue.map((event) {
      final List<InventoryItem> loadedItems = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> dataMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        dataMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          switch (category) {
            case InventoryCategory.classB:
              loadedItems.add(ClassInventory.fromMap(data, key.toString()));
              break;
            case InventoryCategory.office:
              loadedItems.add(OfficeInventory.fromMap(data, key.toString()));
              break;
            case InventoryCategory.legger:
              break; // ditangani LeggerController
          }
        });
      }
      return loadedItems;
    }));
  }

  Future<void> createRecord(String title, InventoryCategory category) async {
    final userId = AuthController.instance.user?.uid;
    if (userId == null) return;

    try {
      final DatabaseReference ref =
          _database.ref('records').child(userId).push();
      final record = InventoryRecord(
        id: ref.key!,
        title: title,
        category: category,
        createdAt: DateTime.now(),
      );
      await ref.set(record.toMap());
      Get.snackbar('Berhasil', 'Catatan dibuat',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat catatan: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteRecord(InventoryRecord record) async {
    final userId = AuthController.instance.user?.uid;
    if (userId == null) return;

    try {
      await _database.ref('records').child(userId).child(record.id).remove();
      if (record.category == InventoryCategory.legger) {
        await _database.ref('legger').child(userId).child(record.id).remove();
      } else {
        await _database.ref('items').child(userId).child(record.id).remove();
      }
      Get.snackbar('Berhasil', 'Catatan dihapus',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus catatan: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateRecord(InventoryRecord record, String newTitle) async {
    final userId = AuthController.instance.user?.uid;
    if (userId == null) return;

    try {
      await _database
          .ref('records')
          .child(userId)
          .child(record.id)
          .update({'title': newTitle});
      Get.snackbar('Berhasil', 'Nama catatan diperbarui',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui catatan: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addItem(InventoryItem item) async {
    final userId = AuthController.instance.user?.uid;
    final recordId = selectedRecord.value?.id;
    if (userId == null || recordId == null) return;

    try {
      final DatabaseReference ref =
          _database.ref('items').child(userId).child(recordId).push();
      final Map<String, dynamic> data = item.toMap();
      data['id'] = ref.key;
      await ref.set(data);
      Get.snackbar('Berhasil', 'Barang ditambahkan',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambah barang: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    final userId = AuthController.instance.user?.uid;
    final recordId = selectedRecord.value?.id;
    if (userId == null || recordId == null) return;

    try {
      await _database
          .ref('items')
          .child(userId)
          .child(recordId)
          .child(item.id)
          .update(item.toMap());
      Get.snackbar('Berhasil', 'Barang diperbarui',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui barang: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteItem(InventoryItem item) async {
    final userId = AuthController.instance.user?.uid;
    final recordId = selectedRecord.value?.id;
    if (userId == null || recordId == null) return;

    try {
      await _database
          .ref('items')
          .child(userId)
          .child(recordId)
          .child(item.id)
          .remove();
      Get.snackbar('Berhasil', 'Barang dihapus',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus barang: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
