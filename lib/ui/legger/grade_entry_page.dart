import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/legger_controller.dart';
import '../../models/legger/student.dart';

/// Halaman daftar siswa untuk input nilai
class GradeEntryPage extends StatelessWidget {
  const GradeEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeggerController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai')),
      body: Obx(() {
        if (ctrl.students.isEmpty) {
          return const Center(
            child: Text('Belum ada siswa.\nTambahkan siswa terlebih dahulu.',
                textAlign: TextAlign.center),
          );
        }
        if (ctrl.surahs.isEmpty) {
          return const Center(
            child: Text('Belum ada surah.\nTambahkan surah terlebih dahulu.',
                textAlign: TextAlign.center),
          );
        }
        if (ctrl.components.isEmpty) {
          return const Center(
            child: Text('Belum ada komponen penilaian.',
                textAlign: TextAlign.center),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.students.length,
          itemBuilder: (context, index) {
            final student = ctrl.students[index];
            return _StudentCard(student: student, ctrl: ctrl, index: index);
          },
        );
      }),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final LeggerController ctrl;
  final int index;

  const _StudentCard({
    required this.student,
    required this.ctrl,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: student.nisn.isNotEmpty ? Text('NISN: ${student.nisn}') : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed('/leggerStudentGrade', arguments: student),
      ),
    );
  }
}
