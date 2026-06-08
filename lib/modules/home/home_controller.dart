import 'package:get/get.dart';
import 'package:tin/data/models/banner_model.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/home_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class HomeController extends GetxController {
  final HomeService service =
      HomeService();

  RxBool isLoading =
      false.obs;

  RxList<BannerModel>
      banners =
      <BannerModel>[].obs;

  RxList<CategoryModel>
      categories =
      <CategoryModel>[].obs;

  RxList<ProductModel>
      products =
      <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
  Get.find<CartController>()
      .loadServerCart();

    loadHomeData();
  }

  Future<void>
      loadHomeData() async {
    try {
      isLoading.value =
          true;

      final bannerData =
          await service
              .getBanners();

      final categoryData =
          await service
              .getCategories();

      final productData =
          await service
              .getProducts();

      banners.value =
          (bannerData as List)
              .map<BannerModel>(
                (e) =>
                    BannerModel
                        .fromJson(
                  e,
                ),
              )
              .toList();

      categories.value =
          (categoryData as List)
              .map<CategoryModel>(
                (e) =>
                    CategoryModel
                        .fromJson(
                  e,
                ),
              )
              .toList();

      products.value =
          (productData as List)
              .map<ProductModel>(
                (e) =>
                    ProductModel
                        .fromJson(
                  e,
                ),
              )
              .toList();
    } catch (e) {
      print(
        "Home Load Error: $e",
      );

      Get.snackbar(
        "Error",
        "Failed to load home data",
      );
    } finally {
      isLoading.value =
          false;
    }
  }

  Future<void>
      refreshHome() async {
    await loadHomeData();
  }
}