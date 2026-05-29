import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../models/inventory_item.dart';
import '../models/class_inventory.dart';
import '../models/office_inventory.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final inventoryController = Get.find<InventoryController>();

  late InventoryCategory selectedCategory;
  InventoryItem? existingItem;

  // Common fields
  String name = '';
  String quantity = '';
  String condition = 'Layak';
  String fundSource = 'BOP';

  // OfficeInventory fields
  String storeQuantity = '';
  String officeNeeds = '';
  String willBePurchased = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = inventoryController.selectedRecord.value!.category;

    if (Get.arguments != null && Get.arguments['item'] != null) {
      existingItem = Get.arguments['item'] as InventoryItem;
      _prefillData();
    }
  }

  void _prefillData() {
    name = existingItem!.name;
    condition = existingItem!.condition;
    fundSource = existingItem!.fundSource;
    quantity = existingItem!.quantity;

    if (existingItem is OfficeInventory) {
      final officeItem = existingItem as OfficeInventory;
      storeQuantity = officeItem.storeQuantity;
      officeNeeds = officeItem.officeNeeds;
      willBePurchased = officeItem.willBePurchased;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = existingItem != null;

    String categoryLabel = '';
    switch (selectedCategory) {
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
        title: Text(isEdit
            ? 'Edit Inventaris $categoryLabel'
            : 'Tambah Inventaris $categoryLabel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ──── Nama Barang (semua jenis) ────
            TextFormField(
              initialValue: name,
              decoration: _inputDecoration('Nama Barang'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Wajib diisi' : null,
              onSaved: (val) => name = val ?? '',
            ),
            const SizedBox(height: 16),

            // ──── KELAS B ────
            if (selectedCategory == InventoryCategory.classB) ...[
              TextFormField(
                initialValue: quantity,
                decoration: _inputDecoration('Jumlah'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => quantity = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: condition,
                decoration: _inputDecoration('Kondisi Barang'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => condition = val ?? 'Layak',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Sumber Dana'),
                initialValue: fundSource,
                items: ['BOP', 'Sekolah']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => fundSource = val ?? 'BOP'),
              ),
            ],

            // ──── KANTOR ────
            if (selectedCategory == InventoryCategory.office) ...[
              TextFormField(
                initialValue: storeQuantity,
                decoration: _inputDecoration('Jumlah di Etalase'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => storeQuantity = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: officeNeeds,
                decoration: _inputDecoration('Kebutuhan Kantor'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => officeNeeds = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: willBePurchased,
                decoration: _inputDecoration('Akan Dibeli'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => willBePurchased = val ?? '',
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submitForm,
              child: Text(
                isEdit ? 'Simpan Perubahan' : 'Simpan',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      InventoryItem newItem;
      final itemId = existingItem?.id ?? '';

      if (selectedCategory == InventoryCategory.classB) {
        newItem = ClassInventory(
          id: itemId,
          name: name,
          quantity: quantity,
          condition: condition,
          fundSource: fundSource,
        );
      } else {
        // office
        newItem = OfficeInventory(
          id: itemId,
          name: name,
          storeQuantity: storeQuantity,
          officeNeeds: officeNeeds,
          willBePurchased: willBePurchased,
        );
      }

      if (existingItem != null) {
        inventoryController.updateItem(newItem);
      } else {
        inventoryController.addItem(newItem);
      }
      Get.back();
    }
  }
}
