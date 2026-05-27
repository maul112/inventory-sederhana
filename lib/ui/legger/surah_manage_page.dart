import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/legger_controller.dart';
import '../../models/legger/surah.dart';

/// Halaman kelola surah (CRUD)
class SurahManagePage extends StatelessWidget {
  const SurahManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeggerController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Surah')),
      body: Obx(() {
        if (ctrl.surahs.isEmpty) {
          return const Center(child: Text('Belum ada surah. Tekan + untuk menambahkan.'));
        }
        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.surahs.length,
          onReorder: (oldIndex, newIndex) {
            // Reorder lokal saja — bisa dikembangkan simpan urutan ke Firebase
          },
          itemBuilder: (context, index) {
            final s = ctrl.surahs[index];
            return Card(
              key: ValueKey(s.id),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(s.name),
                onTap: () => _showDialog(context, ctrl, surah: s),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showDialog(context, ctrl, surah: s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ctrl, s),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context, ctrl),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDialog(BuildContext context, LeggerController ctrl, {Surah? surah}) {
    String name = surah?.name ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(surah == null ? 'Tambah Surah' : 'Edit Surah'),
        content: TextFormField(
          initialValue: name,
          decoration: const InputDecoration(labelText: 'Nama Surah', border: OutlineInputBorder()),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isEmpty) return;
              if (surah == null) {
                ctrl.addSurah(name.trim());
              } else {
                ctrl.updateSurah(surah, name.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, LeggerController ctrl, Surah s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Surah'),
        content: Text('Hapus surah "${s.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ctrl.deleteSurah(s);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
