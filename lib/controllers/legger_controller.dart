import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/legger/student.dart';
import '../models/legger/surah.dart';
import '../models/legger/grading_component.dart';
import 'auth_controller.dart';

class LeggerController extends GetxController {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // State
  RxList<Student> students = <Student>[].obs;
  RxList<Surah> surahs = <Surah>[].obs;
  RxList<GradingComponent> components = <GradingComponent>[].obs;

  /// grades[studentId][surahId][componentId] = nilai (1-20)
  RxMap<String, Map<String, Map<String, int>>> grades =
      <String, Map<String, Map<String, int>>>{}.obs;

  String? _recordId;

  // ─── Komponen default ───────────────────────────────────────────────────────

  static const List<Map<String, String>> defaultComponents = [
    {'name': 'Makhraj', 'type': 'tahsin'},
    {'name': 'Tajwid', 'type': 'tahsin'},
    {'name': 'Kelancaran Baca', 'type': 'tahsin'},
    {'name': 'Kelancaran Hafalan', 'type': 'tahfiz'},
    {'name': "Muraja'ah", 'type': 'tahfiz'},
    {'name': 'Fashahah', 'type': 'tahfiz'},
  ];

  // ─── Binding ─────────────────────────────────────────────────────────────────

  void bindStreams(String recordId) {
    _recordId = recordId;
    final uid = AuthController.instance.user?.uid;
    if (uid == null) return;

    final base = _db.ref('legger').child(uid).child(recordId);

    students.bindStream(base.child('students').onValue.map((e) {
      if (e.snapshot.value == null) return <Student>[];
      final map = Map<String, dynamic>.from(e.snapshot.value as Map);
      return map.entries
          .map((entry) =>
              Student.fromMap(Map<String, dynamic>.from(entry.value), entry.key))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }));

    surahs.bindStream(base.child('surahs').onValue.map((e) {
      if (e.snapshot.value == null) return <Surah>[];
      final map = Map<String, dynamic>.from(e.snapshot.value as Map);
      return map.entries
          .map((entry) =>
              Surah.fromMap(Map<String, dynamic>.from(entry.value), entry.key))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    }));

    components.bindStream(base.child('components').onValue.map((e) {
      if (e.snapshot.value == null) return <GradingComponent>[];
      final map = Map<String, dynamic>.from(e.snapshot.value as Map);
      return map.entries
          .map((entry) => GradingComponent.fromMap(
              Map<String, dynamic>.from(entry.value), entry.key))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    }));

    base.child('grades').onValue.listen((e) {
      if (e.snapshot.value == null) {
        grades.value = {};
        return;
      }
      final raw = Map<String, dynamic>.from(e.snapshot.value as Map);
      final Map<String, Map<String, Map<String, int>>> parsed = {};
      raw.forEach((studentId, surahMap) {
        parsed[studentId] = {};
        final sMap = Map<String, dynamic>.from(surahMap);
        sMap.forEach((surahId, compMap) {
          parsed[studentId]![surahId] = {};
          final cMap = Map<String, dynamic>.from(compMap);
          cMap.forEach((compId, val) {
            parsed[studentId]![surahId]![compId] = (val as num).toInt();
          });
        });
      });
      grades.value = parsed;
    });
  }

  // ─── Inisialisasi default komponen ─────────────────────────────────────────

  Future<void> initDefaultComponents() async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;

    final base = _db.ref('legger').child(uid).child(_recordId!).child('components');
    for (int i = 0; i < defaultComponents.length; i++) {
      final ref = base.push();
      await ref.set({
        'id': ref.key,
        'name': defaultComponents[i]['name'],
        'type': defaultComponents[i]['type'],
        'order': i,
      });
    }
  }

  // ─── CRUD Students ──────────────────────────────────────────────────────────

  Future<void> addStudent(String name, String nisn) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    final ref =
        _db.ref('legger').child(uid).child(_recordId!).child('students').push();
    await ref.set({'id': ref.key, 'name': name, 'nisn': nisn});
    Get.snackbar('Berhasil', 'Siswa ditambahkan', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateStudent(Student s, String newName, String newNisn) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('students')
        .child(s.id)
        .update({'name': newName, 'nisn': newNisn});
    Get.snackbar('Berhasil', 'Data siswa diperbarui', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteStudent(Student s) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('students')
        .child(s.id)
        .remove();
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('grades')
        .child(s.id)
        .remove();
    Get.snackbar('Berhasil', 'Siswa dihapus', snackPosition: SnackPosition.BOTTOM);
  }

  // ─── CRUD Surahs ────────────────────────────────────────────────────────────

  Future<void> addSurah(String name) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    final ref =
        _db.ref('legger').child(uid).child(_recordId!).child('surahs').push();
    await ref.set({'id': ref.key, 'name': name, 'order': surahs.length});
    Get.snackbar('Berhasil', 'Surah ditambahkan', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateSurah(Surah s, String newName) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('surahs')
        .child(s.id)
        .update({'name': newName});
    Get.snackbar('Berhasil', 'Surah diperbarui', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteSurah(Surah s) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('surahs')
        .child(s.id)
        .remove();
    Get.snackbar('Berhasil', 'Surah dihapus', snackPosition: SnackPosition.BOTTOM);
  }

  // ─── CRUD Components ─────────────────────────────────────────────────────────

  Future<void> addComponent(String name, String type) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    final existing = components.where((c) => c.type == type).length;
    final ref = _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('components')
        .push();
    await ref.set({'id': ref.key, 'name': name, 'type': type, 'order': existing});
    Get.snackbar('Berhasil', 'Komponen ditambahkan', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateComponent(GradingComponent c, String newName) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('components')
        .child(c.id)
        .update({'name': newName});
    Get.snackbar('Berhasil', 'Komponen diperbarui', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteComponent(GradingComponent c) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('components')
        .child(c.id)
        .remove();
    Get.snackbar('Berhasil', 'Komponen dihapus', snackPosition: SnackPosition.BOTTOM);
  }

  // ─── Grade Entry ─────────────────────────────────────────────────────────────

  Future<void> setGrade(
      String studentId, String surahId, String componentId, int value) async {
    final uid = AuthController.instance.user?.uid;
    if (uid == null || _recordId == null) return;
    await _db
        .ref('legger')
        .child(uid)
        .child(_recordId!)
        .child('grades')
        .child(studentId)
        .child(surahId)
        .child(componentId)
        .set(value);
  }

  int getGrade(String studentId, String surahId, String componentId) {
    return grades[studentId]?[surahId]?[componentId] ?? 0;
  }

  /// Hitung rata-rata tahsin/tahfiz untuk 1 siswa, 1 surah (nilai sudah ×5)
  double avgForType(String studentId, String surahId, String type) {
    final comps = components.where((c) => c.type == type).toList();
    if (comps.isEmpty) return 0;
    double total = 0;
    for (final c in comps) {
      total += getGrade(studentId, surahId, c.id) * 5;
    }
    return total / comps.length;
  }

  // ─── Export Excel (Formal Leger) ─────────────────────────────────────────────

  Future<void> exportToExcel(String title) async {
    try {
      final tahsinComps = components.where((c) => c.type == 'tahsin').toList();
      final tahfizComps = components.where((c) => c.type == 'tahfiz').toList();

      if (students.isEmpty || surahs.isEmpty) {
        Get.snackbar('Export', 'Data siswa atau surah masih kosong',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final int surahCount = surahs.length;

      // Rows per student block:
      //   tahsinComps rows + 1 TAHSIN avg + tahfizComps rows + 1 TAHFIZ avg
      final int rowsPerStudent =
          tahsinComps.length + 1 + tahfizComps.length + 1;

      // Column layout:  0=No | 1=Nama | 2=Kriteria | 3..=Surah
      const int colNo = 0;
      const int colNama = 1;
      const int colKriteria = 2;
      const int colFirstSurah = 3;
      final int totalCols = colFirstSurah + surahCount;

      // Row layout for headers
      const int rowSchool = 0;    // "TK ISLAM PLUS IBNU UMAR"
      const int rowTitle = 1;     // "LEGGER PENILAIAN TAHFIZ & TAHSIN - ..."
      const int rowKelompok = 2;  // "KELOMPOK : ..."
      const int rowHdrSurah = 3;  // Surah names (rotated 90°)
      const int rowHdrNum = 4;    // Surah ordinal numbers
      const int dataStart = 5;

      // ── Build workbook ──────────────────────────────────────────────────────
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Legger');
      final sheet = excel['Legger'];

      // ── Helpers ────────────────────────────────────────────────────────────
      CellIndex ci(int col, int row) =>
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);

      void writeCell(int col, int row, CellValue? val) {
        if (val != null) sheet.cell(ci(col, row)).value = val;
      }

      void styleCell(
        int col,
        int row, {
        bool bold = false,
        int fontSize = 8,
        HorizontalAlign hAlign = HorizontalAlign.Center,
        VerticalAlign vAlign = VerticalAlign.Center,
        bool wrap = false,
        int rotation = 0,
        ExcelColor? bg,
        bool borders = true,
      }) {
        final thinBorder = Border(borderStyle: BorderStyle.Thin);
        sheet.cell(ci(col, row)).cellStyle = CellStyle(
          bold: bold,
          fontSize: fontSize,
          horizontalAlign: hAlign,
          verticalAlign: vAlign,
          textWrapping: wrap ? TextWrapping.WrapText : TextWrapping.Clip,
          rotation: rotation,
          backgroundColorHex: bg ?? ExcelColor.none,
          leftBorder: borders ? thinBorder : null,
          rightBorder: borders ? thinBorder : null,
          topBorder: borders ? thinBorder : null,
          bottomBorder: borders ? thinBorder : null,
        );
      }

      // ── HEADER BLOCK ───────────────────────────────────────────────────────

      // Row 0 – School name
      writeCell(colNo, rowSchool, TextCellValue('TK ISLAM PLUS IBNU UMAR'));
      sheet.merge(ci(colNo, rowSchool), ci(totalCols - 1, rowSchool));
      styleCell(colNo, rowSchool,
          bold: true, fontSize: 14, borders: false);

      // Row 1 – Legger title
      writeCell(colNo, rowTitle,
          TextCellValue('LEGGER PENILAIAN TAHFIZ & TAHSIN  —  $title'));
      sheet.merge(ci(colNo, rowTitle), ci(totalCols - 1, rowTitle));
      styleCell(colNo, rowTitle,
          bold: true, fontSize: 11, borders: false);

      // Row 2 – Kelompok / Semester info
      writeCell(colNo, rowKelompok,
          TextCellValue('KELOMPOK    :    $title'));
      sheet.merge(ci(colNo, rowKelompok), ci(totalCols - 1, rowKelompok));
      styleCell(colNo, rowKelompok,
          bold: true, fontSize: 10, hAlign: HorizontalAlign.Left, borders: false);

      // ── COLUMN HEADER ROW – Surah names (rotated) ──────────────────────────
      final ExcelColor headerBg = ExcelColor.fromHexString('BFBFBF');

      // No (merged rows 3-4)
      writeCell(colNo, rowHdrSurah, TextCellValue('No'));
      sheet.merge(ci(colNo, rowHdrSurah), ci(colNo, rowHdrNum));
      styleCell(colNo, rowHdrSurah, bold: true, bg: headerBg);

      // Nama Siswa (merged rows 3-4)
      writeCell(colNama, rowHdrSurah, TextCellValue('Nama Siswa'));
      sheet.merge(ci(colNama, rowHdrSurah), ci(colNama, rowHdrNum));
      styleCell(colNama, rowHdrSurah, bold: true, bg: headerBg, wrap: true);

      // Kriteria Penilaian (merged rows 3-4)
      writeCell(colKriteria, rowHdrSurah, TextCellValue('Nama Surat / Kriteria Penilaian'));
      sheet.merge(ci(colKriteria, rowHdrSurah), ci(colKriteria, rowHdrNum));
      styleCell(colKriteria, rowHdrSurah,
          bold: true, bg: headerBg, wrap: true);

      // Surah name (rotated) in row 3 + ordinal number in row 4
      for (int si = 0; si < surahCount; si++) {
        final col = colFirstSurah + si;
        writeCell(col, rowHdrSurah, TextCellValue(surahs[si].name));
        styleCell(col, rowHdrSurah,
            bold: true, rotation: 90, bg: headerBg);
        writeCell(col, rowHdrNum, IntCellValue(si + 1));
        styleCell(col, rowHdrNum, bold: true, bg: headerBg);
      }

      // ── DATA ROWS (one block of rowsPerStudent rows per student) ───────────
      final ExcelColor tahsinBg  = ExcelColor.fromHexString('FFF2CC');  // pale yellow
      final ExcelColor tahfizBg  = ExcelColor.fromHexString('DDEEFF');  // pale blue
      final ExcelColor avgBg     = ExcelColor.fromHexString('E2EFDA');  // pale green
      final ExcelColor nameBg    = ExcelColor.fromHexString('F2F2F2');  // very light gray

      for (int sIdx = 0; sIdx < students.length; sIdx++) {
        final student = students[sIdx];
        final int r0 = dataStart + sIdx * rowsPerStudent;
        final int r1 = r0 + rowsPerStudent - 1;

        // ─ No column (merged all rows for this student)
        writeCell(colNo, r0, IntCellValue(sIdx + 1));
        sheet.merge(ci(colNo, r0), ci(colNo, r1));
        styleCell(colNo, r0, bold: true, fontSize: 9, bg: nameBg);
        for (int r = r0 + 1; r <= r1; r++) {
          styleCell(colNo, r, bg: nameBg);
        }

        // ─ Nama column (merged all rows, name + optional NISN)
        final nameText = student.nisn.isNotEmpty
            ? '${student.name}\nNISN: ${student.nisn}'
            : student.name;
        writeCell(colNama, r0, TextCellValue(nameText));
        sheet.merge(ci(colNama, r0), ci(colNama, r1));
        styleCell(colNama, r0,
            bold: true,
            fontSize: 9,
            hAlign: HorizontalAlign.Left,
            vAlign: VerticalAlign.Center,
            wrap: true,
            bg: nameBg);
        for (int r = r0 + 1; r <= r1; r++) {
          styleCell(colNama, r, bg: nameBg);
        }

        // ─ TAHSIN criteria rows ─────────────────────────────────────────────
        for (int ci2 = 0; ci2 < tahsinComps.length; ci2++) {
          final comp = tahsinComps[ci2];
          final int row = r0 + ci2;

          writeCell(colKriteria, row, TextCellValue(comp.name));
          styleCell(colKriteria, row,
              hAlign: HorizontalAlign.Left,
              wrap: true,
              bg: tahsinBg,
              fontSize: 8);

          for (int si = 0; si < surahCount; si++) {
            final col = colFirstSurah + si;
            final g = getGrade(student.id, surahs[si].id, comp.id);
            if (g > 0) writeCell(col, row, IntCellValue(g * 5));
            styleCell(col, row, bg: tahsinBg, fontSize: 8);
          }
        }

        // ─ TAHSIN average row ────────────────────────────────────────────────
        final int tahsinAvgRow = r0 + tahsinComps.length;
        writeCell(colKriteria, tahsinAvgRow, TextCellValue('TAHSIN'));
        styleCell(colKriteria, tahsinAvgRow,
            bold: true, bg: avgBg, fontSize: 8);

        for (int si = 0; si < surahCount; si++) {
          final col = colFirstSurah + si;
          final avg = avgForType(student.id, surahs[si].id, 'tahsin');
          if (avg > 0) {
            writeCell(col, tahsinAvgRow,
                DoubleCellValue(double.parse(avg.toStringAsFixed(1))));
          }
          styleCell(col, tahsinAvgRow, bold: true, bg: avgBg, fontSize: 8);
        }

        // ─ TAHFIZ criteria rows ─────────────────────────────────────────────
        for (int ci2 = 0; ci2 < tahfizComps.length; ci2++) {
          final comp = tahfizComps[ci2];
          final int row = r0 + tahsinComps.length + 1 + ci2;

          writeCell(colKriteria, row, TextCellValue(comp.name));
          styleCell(colKriteria, row,
              hAlign: HorizontalAlign.Left,
              wrap: true,
              bg: tahfizBg,
              fontSize: 8);

          for (int si = 0; si < surahCount; si++) {
            final col = colFirstSurah + si;
            final g = getGrade(student.id, surahs[si].id, comp.id);
            if (g > 0) writeCell(col, row, IntCellValue(g * 5));
            styleCell(col, row, bg: tahfizBg, fontSize: 8);
          }
        }

        // ─ TAHFIZ average row ────────────────────────────────────────────────
        final int tahfizAvgRow = r0 + tahsinComps.length + 1 + tahfizComps.length;
        writeCell(colKriteria, tahfizAvgRow, TextCellValue('TAHFIZ'));
        styleCell(colKriteria, tahfizAvgRow,
            bold: true, bg: avgBg, fontSize: 8);

        for (int si = 0; si < surahCount; si++) {
          final col = colFirstSurah + si;
          final avg = avgForType(student.id, surahs[si].id, 'tahfiz');
          if (avg > 0) {
            writeCell(col, tahfizAvgRow,
                DoubleCellValue(double.parse(avg.toStringAsFixed(1))));
          }
          styleCell(col, tahfizAvgRow, bold: true, bg: avgBg, fontSize: 8);
        }
      }

      // ── COLUMN WIDTHS ──────────────────────────────────────────────────────
      sheet.setColumnWidth(colNo, 4.0);
      sheet.setColumnWidth(colNama, 22.0);
      sheet.setColumnWidth(colKriteria, 18.0);
      for (int si = 0; si < surahCount; si++) {
        sheet.setColumnWidth(colFirstSurah + si, 5.5);
      }

      // ── ROW HEIGHTS ───────────────────────────────────────────────────────
      sheet.setRowHeight(rowSchool, 22.0);
      sheet.setRowHeight(rowTitle, 18.0);
      sheet.setRowHeight(rowKelompok, 16.0);
      sheet.setRowHeight(rowHdrSurah, 80.0); // tall for rotated surah names
      sheet.setRowHeight(rowHdrNum, 14.0);
      // Criterion rows: slightly taller for wrap text
      for (int sIdx = 0; sIdx < students.length; sIdx++) {
        final int r0 = dataStart + sIdx * rowsPerStudent;
        for (int r = r0; r < r0 + rowsPerStudent; r++) {
          sheet.setRowHeight(r, 16.0);
        }
      }

      // ── SAVE & SHARE ───────────────────────────────────────────────────────
      final safe = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Legger_${safe}_$ts.xlsx';

      if (kIsWeb) {
        excel.save(fileName: fileName);
      } else {
        final bytes = excel.save();
        if (bytes != null) {
          final dir = await getApplicationDocumentsDirectory();
          final path = '${dir.path}/$fileName';
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes);
          await Share.shareXFiles(
            [XFile(path)],
            text: 'Legger $title',
          );
        }
      }
    } catch (e) {
      Get.snackbar('Export Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

