import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/legger_controller.dart';
import '../../models/legger/grading_component.dart';

/// Halaman kelola komponen penilaian (Tahsin & Tahfiz), dengan 2 tab
class ComponentManagePage extends StatelessWidget {
  const ComponentManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeggerController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Komponen Penilaian'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Tahsin'),
              Tab(text: 'Tahfiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ComponentList(type: 'tahsin', ctrl: ctrl),
            _ComponentList(type: 'tahfiz', ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

class _ComponentList extends StatelessWidget {
  final String type;
  final LeggerController ctrl;

  const _ComponentList({required this.type, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final comps = ctrl.components.where((c) => c.type == type).toList();
      return Scaffold(
        body: comps.isEmpty
            ? const Center(child: Text('Belum ada komponen. Tekan + untuk menambah.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: comps.length,
                itemBuilder: (context, index) {
                  final c = comps[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(c.name),
                      onTap: () => _showDialog(context, comp: c),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showDialog(context, comp: c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, c),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fab_$type',
          onPressed: () => _showDialog(context),
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  void _showDialog(BuildContext context, {GradingComponent? comp}) {
    String name = comp?.name ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(comp == null ? 'Tambah Komponen ${type == 'tahsin' ? 'Tahsin' : 'Tahfiz'}' : 'Edit Komponen'),
        content: TextFormField(
          initialValue: name,
          decoration: const InputDecoration(
              labelText: 'Nama Komponen', border: OutlineInputBorder()),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isEmpty) return;
              if (comp == null) {
                ctrl.addComponent(name.trim(), type);
              } else {
                ctrl.updateComponent(comp, name.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, GradingComponent c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Komponen'),
        content: Text('Hapus komponen "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ctrl.deleteComponent(c);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
