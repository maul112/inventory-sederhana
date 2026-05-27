import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/legger_controller.dart';
import 'student_manage_page.dart';
import 'surah_manage_page.dart';
import 'component_manage_page.dart';
import 'grade_entry_page.dart';

/// Halaman utama Legger: menu kelola siswa, surah, komponen, dan input nilai
class LeggerDetailPage extends StatefulWidget {
  const LeggerDetailPage({super.key});

  @override
  State<LeggerDetailPage> createState() => _LeggerDetailPageState();
}

class _LeggerDetailPageState extends State<LeggerDetailPage> {
  late LeggerController leggerCtrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final inventoryCtrl = Get.find<InventoryController>();
    final record = inventoryCtrl.selectedRecord.value!;

    // Inject LeggerController jika belum ada
    if (!Get.isRegistered<LeggerController>()) {
      Get.put(LeggerController());
    }
    leggerCtrl = Get.find<LeggerController>();

    // Bind streams
    leggerCtrl.bindStreams(record.id);

    // Cek apakah komponen sudah ada, jika belum buat default
    Future.delayed(const Duration(milliseconds: 800), () async {
      if (leggerCtrl.components.isEmpty && !_initialized) {
        _initialized = true;
        await leggerCtrl.initDefaultComponents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryCtrl = Get.find<InventoryController>();
    final record = inventoryCtrl.selectedRecord.value!;

    return Scaffold(
      appBar: AppBar(
        title: Text(record.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Excel',
            onPressed: () => leggerCtrl.exportToExcel(record.title),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          record.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          '${leggerCtrl.students.length} Siswa · '
                          '${leggerCtrl.surahs.length} Surah · '
                          '${leggerCtrl.components.where((c) => c.type == 'tahsin').length} Komponen Tahsin · '
                          '${leggerCtrl.components.where((c) => c.type == 'tahfiz').length} Komponen Tahfiz',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu items
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _MenuCard(
                    icon: Icons.people,
                    label: 'Kelola Siswa',
                    color: Colors.blue,
                    onTap: () => Get.to(() => const StudentManagePage()),
                  ),
                  _MenuCard(
                    icon: Icons.menu_book,
                    label: 'Kelola Surah',
                    color: Colors.green,
                    onTap: () => Get.to(() => const SurahManagePage()),
                  ),
                  _MenuCard(
                    icon: Icons.tune,
                    label: 'Komponen Penilaian',
                    color: Colors.purple,
                    onTap: () => Get.to(() => const ComponentManagePage()),
                  ),
                  _MenuCard(
                    icon: Icons.grade,
                    label: 'Input Nilai',
                    color: Colors.orange,
                    onTap: () => Get.to(() => const GradeEntryPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
