import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/inventory_item.dart';
import '../models/inventory_record.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final InventoryController inventoryController = Get.find<InventoryController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Catatan Inventaris'),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
              themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
            )),
            onPressed: themeController.toggleTheme,
          ),
          PopupMenuButton<Color>(
            icon: const Icon(Icons.color_lens),
            tooltip: 'Ubah Warna Tema',
            onSelected: (color) {
              themeController.changeColor(color);
            },
            itemBuilder: (BuildContext context) {
              final colors = [
                const Color(0xFF00B4D8), // Default Teal
                const Color(0xFF673AB7), // Purple
                const Color(0xFF4CAF50), // Green
                const Color(0xFFFF9800), // Orange
                const Color(0xFFE91E63), // Pink
              ];
              return colors.map((color) {
                return PopupMenuItem<Color>(
                  value: color,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Pilih Warna'),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: AuthController.instance.user?.photoURL != null
                  ? NetworkImage(AuthController.instance.user!.photoURL!)
                  : null,
              child: AuthController.instance.user?.photoURL == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                AuthController.instance.signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    AuthController.instance.user?.email ?? 'User',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Keluar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        if (inventoryController.records.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada folder catatan.\nSilakan tekan tombol + untuk membuat baru.',
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inventoryController.records.length,
          itemBuilder: (context, index) {
            final record = inventoryController.records[index];
            String categoryLabel = '';
            switch (record.category) {
              case InventoryCategory.classB: categoryLabel = 'Kelas B'; break;
              case InventoryCategory.office: categoryLabel = 'Kantor'; break;
              case InventoryCategory.legger: categoryLabel = 'Legger'; break;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.folder, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(
                  record.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Jenis: $categoryLabel\nDibuat: ${DateFormat('dd MMM yyyy, HH:mm').format(record.createdAt)}',
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditRecordDialog(context, record),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, record),
                    ),
                  ],
                ),
                onTap: () {
                  inventoryController.selectRecord(record);
                  Get.toNamed('/recordDetail');
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context),
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }

  void _showEditRecordDialog(BuildContext context, InventoryRecord record) {
    String newTitle = record.title;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Nama Catatan'),
          content: TextFormField(
            initialValue: record.title,
            decoration: const InputDecoration(
              labelText: 'Nama Catatan',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => newTitle = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  inventoryController.updateRecord(record, newTitle.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    String title = '';
    InventoryCategory selectedCategory = InventoryCategory.classB;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Buat Folder Catatan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nama Catatan (misal: Smt 1 2024)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<InventoryCategory>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Inventaris',
                      border: OutlineInputBorder(),
                    ),
                    items: InventoryCategory.values.map((category) {
                      String label = '';
                      switch (category) {
                        case InventoryCategory.classB: label = 'Kelas B'; break;
                        case InventoryCategory.office: label = 'Kantor'; break;
                        case InventoryCategory.legger: label = 'Legger (Tahfiz & Tahsin)'; break;
                      }
                      return DropdownMenuItem(value: category, child: Text(label));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedCategory = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.trim().isNotEmpty) {
                      inventoryController.createRecord(title.trim(), selectedCategory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Buat'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _confirmDelete(BuildContext context, InventoryRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Folder'),
        content: Text('Yakin ingin menghapus folder "${record.title}" beserta isinya? Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              inventoryController.deleteRecord(record);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
