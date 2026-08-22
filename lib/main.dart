import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/socket/socket_service.dart';

import 'core/network/dio_client.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/bindings/app_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Local storage init
  await GetStorage.init();

  // 🔥 API client init
  DioClient.init();
  SocketService().connect();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Marketplace",
      theme: AppTheme.lightTheme,

      // 🔥 ALL CONTROLLERS LOAD HERE
      initialBinding: AppBinding(),

      // 🔥 ROUTES
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}