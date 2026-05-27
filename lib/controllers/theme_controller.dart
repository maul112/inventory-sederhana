import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = false.obs;
  Rx<Color> primaryColor = const Color(0xFF00B4D8).obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // Pemicu pembaruan tema tidak lagi Get.changeThemeMode langsung di sini
    // Karena GetMaterialApp menggunakan Obx, perubahan Rx cukup untuk memicu rebuild
  }

  void changeColor(Color color) {
    primaryColor.value = color;
  }
}
