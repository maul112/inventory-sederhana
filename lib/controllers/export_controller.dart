import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/inventory_item.dart';
import '../models/class_inventory.dart';
import '../models/office_inventory.dart';

class ExportController extends GetxController {
  Future<void> exportToExcel(
      List<InventoryItem> items, InventoryCategory category, String title) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];

      List<CellValue> headers = [
        TextCellValue('No'),
        TextCellValue('Nama Barang'),
      ];
      if (category == InventoryCategory.classB) {
        headers.addAll([
          TextCellValue('Jumlah'),
          TextCellValue('Kondisi Barang'),
          TextCellValue('Sumber Dana'),
        ]);
      } else if (category == InventoryCategory.office) {
        headers.addAll([
          TextCellValue('Jumlah di Etalase'),
          TextCellValue('Kebutuhan Kantor'),
          TextCellValue('Yang Akan Dibeli'),
        ]);
      }
      sheet.appendRow(headers);

      for (int i = 0; i < items.length; i++) {
        var item = items[i];
        List<CellValue> row = [
          IntCellValue(i + 1),
          TextCellValue(item.name),
        ];
        if (item is ClassInventory) {
          row.addAll([
            TextCellValue(item.quantity),
            TextCellValue(item.condition),
            TextCellValue(item.fundSource),
          ]);
        } else if (item is OfficeInventory) {
          row.addAll([
            TextCellValue(item.storeQuantity),
            TextCellValue(item.officeNeeds),
            TextCellValue(item.willBePurchased),
          ]);
        }
        sheet.appendRow(row);
      }

      String safeTitle =
          title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'Inventaris_${safeTitle}_$timestamp.xlsx';

      if (kIsWeb) {
        excel.save(fileName: fileName);
      } else {
        var fileBytes = excel.save();
        if (fileBytes != null) {
          Directory directory = await getApplicationDocumentsDirectory();
          String filePath = '${directory.path}/$fileName';
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
          await Share.shareXFiles(
            [XFile(filePath)],
            text: 'Export Inventaris $title',
          );
        }
      }
    } catch (e) {
      Get.snackbar('Export Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
