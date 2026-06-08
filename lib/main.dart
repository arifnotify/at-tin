import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/network/dio_client.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  await GetStorage.init();
   DioClient.init(); // 🔥 ADD THIS (IMPORTANT)
   Get.put(AuthController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(LocationController(), permanent: true);


  runApp(
    const MyApp(),
  );
}

class MyApp
    extends StatelessWidget {

  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return GetMaterialApp(

      debugShowCheckedModeBanner:
          false,

      title:
          "Marketplace",

      theme:
          AppTheme.lightTheme,

      initialRoute:
          AppRoutes.splash,

      getPages:
          AppPages.routes,
    );
  }
}