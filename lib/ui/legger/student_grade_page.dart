import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/legger_controller.dart';
import '../../models/legger/student.dart';
import '../../models/legger/surah.dart';
import '../../models/legger/grading_component.dart';

/// Halaman input nilai 1 siswa — menampilkan semua surah dan komponen
class StudentGradePage extends StatelessWidget {
  const StudentGradePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LeggerController>();
    final student = Get.arguments as Student;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nilai: ${student.name}'),
      ),
      body: Obx(() {
        final surahs = ctrl.surahs;
        if (surahs.isEmpty) {
          return const Center(child: Text('Belum ada surah yang ditambahkan.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            return _SurahGradeCard(
              student: student,
              surah: surahs[index],
              ctrl: ctrl,
            );
          },
        );
      }),
    );
  }
}

class _SurahGradeCard extends StatelessWidget {
  final Student student;
  final Surah surah;
  final LeggerController ctrl;

  const _SurahGradeCard({
    required this.student,
    required this.surah,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final tahsinComps = ctrl.components.where((c) => c.type == 'tahsin').toList();
    final tahfizComps = ctrl.components.where((c) => c.type == 'tahfiz').toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Surah
            Row(
              children: [
                Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  surah.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Tahsin
            if (tahsinComps.isNotEmpty) ...[
              _SectionHeader(label: 'Tahsin', color: Colors.teal),
              const SizedBox(height: 8),
              ...tahsinComps.map((c) => _GradeField(
                    student: student,
                    surah: surah,
                    component: c,
                    ctrl: ctrl,
                  )),
              _AverageRow(student: student, surah: surah, type: 'tahsin', ctrl: ctrl),
              const SizedBox(height: 12),
            ],

            // Tahfiz
            if (tahfizComps.isNotEmpty) ...[
              _SectionHeader(label: 'Tahfiz', color: Colors.orange),
              const SizedBox(height: 8),
              ...tahfizComps.map((c) => _GradeField(
                    student: student,
                    surah: surah,
                    component: c,
                    ctrl: ctrl,
                  )),
              _AverageRow(student: student, surah: surah, type: 'tahfiz', ctrl: ctrl),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _GradeField extends StatefulWidget {
  final Student student;
  final Surah surah;
  final GradingComponent component;
  final LeggerController ctrl;

  const _GradeField({
    required this.student,
    required this.surah,
    required this.component,
    required this.ctrl,
  });

  @override
  State<_GradeField> createState() => _GradeFieldState();
}

class _GradeFieldState extends State<_GradeField> {
  late TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.ctrl.getGrade(
        widget.student.id, widget.surah.id, widget.component.id);
    _textCtrl = TextEditingController(text: existing > 0 ? existing.toString() : '');
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.component.name, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _textCtrl,
              decoration: InputDecoration(
                hintText: '1-20',
                suffixText: '×5=${_calcDisplay()}',
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                final parsed = int.tryParse(v) ?? 0;
                final clamped = parsed.clamp(0, 20);
                widget.ctrl.setGrade(
                    widget.student.id, widget.surah.id, widget.component.id, clamped);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  String _calcDisplay() {
    final v = int.tryParse(_textCtrl.text) ?? 0;
    return '${(v.clamp(0, 20) * 5)}';
  }
}

class _AverageRow extends StatelessWidget {
  final Student student;
  final Surah surah;
  final String type;
  final LeggerController ctrl;

  const _AverageRow({
    required this.student,
    required this.surah,
    required this.type,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final avg = ctrl.avgForType(student.id, surah.id, type);
      final color = type == 'tahsin' ? Colors.teal : Colors.orange;
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Rata-rata ${type == 'tahsin' ? 'Tahsin' : 'Tahfiz'}: ',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              avg.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      );
    });
  }
}
