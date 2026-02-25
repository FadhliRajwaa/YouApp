import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(StorageKeys.accessToken);
  runApp(YouApp(isLoggedIn: token != null && token.isNotEmpty));
}

class YouApp extends StatelessWidget {
  final bool isLoggedIn;
  const YouApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'YouApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: isLoggedIn ? AppRoutes.profile : AppRoutes.landing,
      getPages: AppPages.pages,
    );
  }
}
