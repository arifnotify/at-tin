import 'package:get/get.dart';
import 'package:tin/data/models/banner_model.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/home_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class HomeController extends GetxController {
  final HomeService service = HomeService();

  RxBool isLoading = false.obs;

  RxList<BannerModel> banners = <BannerModel>[].obs;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    Get.find<CartController>().loadServerCart();

    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;

      /// =========================
      /// BANNERS
      /// =========================
      final bannerData = await service.getBanners();

      banners.value = (bannerData as List)
          .map((e) => BannerModel.fromJson(e))
          .toList();

      /// =========================
      /// 🔥 IMPORTANT CHANGE HERE
      /// MAIN CATEGORIES ONLY
      /// =========================
      final categoryData =
          await service.getMainCategories(); // ❗ FIXED

      categories.value = (categoryData as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();

      /// =========================
      /// PRODUCTS
      /// =========================
      final productData = await service.getProducts();

      products.value = (productData as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Home Load Error: $e");

      Get.snackbar(
        "Error",
        "Failed to load home data",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHome() async {
    await loadHomeData();
  }
}