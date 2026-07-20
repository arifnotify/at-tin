import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/core/bindings/search_binding.dart';
import 'package:tin/core/routes/app_routes.dart';

import 'package:tin/modules/address/address_page.dart';
import 'package:tin/modules/auth/auth_binding.dart';
import 'package:tin/modules/auth/login_page.dart';
import 'package:tin/modules/auth/otp_page.dart';
import 'package:tin/modules/cart/cart_screen.dart';
import 'package:tin/modules/home/category/main_categories_page.dart';
import 'package:tin/modules/home/category/sub_category.dart';
import 'package:tin/modules/home/home_screen.dart';
import 'package:tin/modules/order/order_success_page.dart';
import 'package:tin/modules/order/order_summary_page.dart';
import 'package:tin/modules/order/tracking_orders_page.dart';
import 'package:tin/modules/order/tracking_page.dart';
import 'package:tin/modules/product/product_details_page.dart';
import 'package:tin/modules/search/search_screen.dart';
import 'package:tin/modules/splash/splash_binding.dart';
import 'package:tin/modules/splash/splash_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),

    GetPage(
      name: AppRoutes.cart,
      page: () => const CartPage(),
    ),

    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsPage(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.otp,
      page: () => OtpPage(),
    ),

   /* GetPage(
      name: AppRoutes.address,
      page: () => const AddressPage(),
    ),*/

    GetPage(
      name: AppRoutes.ordersuccess,
      page: () => const OrderSuccessPage(),
    ),

  /*  GetPage(
      name: AppRoutes.ordersummary,
      page: () => const OrderSummaryPage(),
    ),*/

    // NEW PAGE
    GetPage(
      name: AppRoutes.subCategory,
      page: () => SubCategoryPage(),
    ),

      GetPage(
      name: AppRoutes.allCategories,
      page: () => const AllCategoriesPage(),
    ),

    GetPage(
  name:
      AppRoutes.search,
  page: () =>
      SearchScreen(),
  binding:
      SearchBinding(),
),

GetPage(
  name: AppRoutes.trackingOrders,
  page: () => const TrackingOrdersPage(),
),

GetPage(
  name: AppRoutes.tracking,
  page: () {
    final orderId = Get.parameters['id'];

    if (orderId == null) {
      return const Scaffold(
        body: Center(child: Text("No Order ID Found")),
      );
    }

    return OrderTrackingPage(orderId: orderId);
  },
),
  ];
}