import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/export_controller.dart';
import '../models/inventory_item.dart';
import '../models/office_inventory.dart';
import 'legger/legger_detail_page.dart';

class RecordDetailPage extends StatelessWidget {
  RecordDetailPage({super.key});

  final InventoryController inventoryController = Get.find<InventoryController>();
  final ExportController exportController = Get.put(ExportController());

  @override
  Widget build(BuildContext context) {
    final record = inventoryController.selectedRecord.value;
    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Tidak ada catatan yang dipilih')),
      );
    }

    // Jika legger → tampilkan LeggerDetailPage
    if (record.category == InventoryCategory.legger) {
      return const LeggerDetailPage();
    }

    String categoryLabel = '';
    switch (record.category) {
      case InventoryCategory.classB:
        categoryLabel = 'Kelas B';
        break;
      case InventoryCategory.office:
        categoryLabel = 'Kantor';
        break;
      case InventoryCategory.legger:
        categoryLabel = 'Legger';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${record.title} ($categoryLabel)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              exportController.exportToExcel(
                inventoryController.items,
                record.category,
                record.title,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (inventoryController.items.isEmpty) {
          return const Center(
              child: Text('Belum ada data barang di dalam catatan ini.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: inventoryController.items.length,
          itemBuilder: (context, index) {
            final item = inventoryController.items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item is OfficeInventory) ...[
                        Text('Di Etalase: ${item.storeQuantity}'),
                        Text('Kebutuhan: ${item.officeNeeds}'),
                        Text(
                          'Akan Dibeli: ${item.willBePurchased}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (item.willBePurchased.isNotEmpty && item.willBePurchased != '0' && item.willBePurchased.toLowerCase() != 'kosong')
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ] else ...[
                        Text(
                            'Jumlah: ${item.quantity} | Kondisi: ${item.condition}'),
                        Text('Dana: ${item.fundSource}'),
                      ],
                    ],
                  ),
                ),
                isThreeLine: true,
                onTap: () =>
                    Get.toNamed('/addItem', arguments: {'item': item}),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          Get.toNamed('/addItem', arguments: {'item': item}),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, item),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/addItem'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              inventoryController.deleteItem(item);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
