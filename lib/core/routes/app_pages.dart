import 'package:get/get.dart';
import 'package:tin/modules/address/address_page.dart';
import 'package:tin/modules/auth/auth_binding.dart';
import 'package:tin/modules/auth/login_page.dart';
import 'package:tin/modules/auth/otp_page.dart';
import 'package:tin/modules/cart/cart_screen.dart';
import 'package:tin/modules/home/home_screen.dart';
import 'package:tin/modules/order/order_success_page.dart';
import 'package:tin/modules/order/order_summary_page.dart';
import 'package:tin/modules/product_details/product_details_page.dart';
import 'package:tin/modules/splash/splash_binding.dart';
import 'package:tin/modules/splash/splash_screen.dart';

import 'app_routes.dart';

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
      page: () =>
          const ProductDetailsPage(),
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

    GetPage(
        name: AppRoutes.address,
        page: () => const AddressPage(),
      ),

    GetPage(
        name: AppRoutes.ordersuccess,
        page: () =>
            const OrderSuccessPage(),
      ),
    
    GetPage(
        name: AppRoutes.ordersummary,
        page: () => const OrderSummaryPage(),
      ),
  ];
}