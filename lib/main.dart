import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/inventory_controller.dart';
import 'controllers/theme_controller.dart';
import 'ui/theme.dart';
import 'ui/login_page.dart';
import 'ui/home_page.dart';
import 'ui/record_detail_page.dart';
import 'ui/add_item_page.dart';
import 'ui/legger/legger_detail_page.dart';
import 'ui/legger/student_manage_page.dart';
import 'ui/legger/surah_manage_page.dart';
import 'ui/legger/component_manage_page.dart';
import 'ui/legger/grade_entry_page.dart';
import 'ui/legger/student_grade_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inject Controllers
  Get.put(AuthController());
  Get.put(CategoryController());
  Get.put(InventoryController());
  Get.put(ThemeController());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Inventaris TK',
          theme: AppTheme.lightTheme(themeController.primaryColor.value),
          darkTheme: AppTheme.darkTheme(themeController.primaryColor.value),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: '/login',
          getPages: [
            GetPage(name: '/login', page: () => const LoginPage()),
            GetPage(name: '/home', page: () => HomePage()),
            GetPage(name: '/recordDetail', page: () => RecordDetailPage()),
            GetPage(name: '/addItem', page: () => const AddItemPage()),
            // Legger routes
            GetPage(name: '/leggerDetail', page: () => const LeggerDetailPage()),
            GetPage(name: '/leggerStudents', page: () => const StudentManagePage()),
            GetPage(name: '/leggerSurahs', page: () => const SurahManagePage()),
            GetPage(name: '/leggerComponents', page: () => const ComponentManagePage()),
            GetPage(name: '/leggerGradeEntry', page: () => const GradeEntryPage()),
            GetPage(name: '/leggerStudentGrade', page: () => const StudentGradePage()),
          ],
          debugShowCheckedModeBanner: false,
        ));
  }
}
