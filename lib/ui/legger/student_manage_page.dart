import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/legger_controller.dart';
import '../../models/legger/student.dart';

/// Halaman kelola siswa (CRUD)
class StudentManagePage extends StatelessWidget {
  const StudentManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeggerController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Siswa')),
      body: Obx(() {
        if (ctrl.students.isEmpty) {
          return const Center(child: Text('Belum ada siswa. Tekan + untuk menambahkan.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.students.length,
          itemBuilder: (context, index) {
            final s = ctrl.students[index];
            return Card(
              child: ListTile(
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: s.nisn.isNotEmpty ? Text('NISN: ${s.nisn}') : null,
                onTap: () => _showDialog(context, ctrl, student: s),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showDialog(context, ctrl, student: s),
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

  void _showDialog(BuildContext context, LeggerController ctrl, {Student? student}) {
    String name = student?.name ?? '';
    String nisn = student?.nisn ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(student == null ? 'Tambah Siswa' : 'Edit Siswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Nama Siswa', border: OutlineInputBorder()),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: nisn,
              decoration: const InputDecoration(
                  labelText: 'NISN (opsional)', border: OutlineInputBorder()),
              onChanged: (v) => nisn = v,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isEmpty) return;
              if (student == null) {
                ctrl.addStudent(name.trim(), nisn.trim());
              } else {
                ctrl.updateStudent(student, name.trim(), nisn.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, LeggerController ctrl, Student s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content: Text('Hapus ${s.name} beserta semua nilainya?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              ctrl.deleteStudent(s);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
