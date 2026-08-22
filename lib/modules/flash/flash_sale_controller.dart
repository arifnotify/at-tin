import 'package:get/get.dart';
import 'package:tin/data/models/flash_sale_model.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/flash_sale_service.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/location/location_controller.dart';

class FlashSaleController extends GetxController {
  final FlashSaleService _flashSaleService = FlashSaleService();

  // =========================================================
  // STATE
  // =========================================================

  final RxBool isLoading = false.obs;

  final RxString flashSaleTitle = ''.obs;

  final RxList<ProductModel> products = <ProductModel>[].obs;

  // =========================================================
  // USER LOCATION ID
  // =========================================================

  String _getUserLocationId() {
    if (Get.isRegistered<LocationController>()) {
      final locationController = Get.find<LocationController>();

      return locationController.box
              .read("locationId")
              ?.toString() ??
          "";
    }

    return "";
  }

  // =========================================================
  // FETCH FLASH SALE BY ID
  // =========================================================

  Future<void> fetchFlashSaleById(String flashSaleId) async {
    try {
      isLoading.value = true;

      products.clear();
      flashSaleTitle.value = '';

      // =====================================================
      // API CALL
      // =====================================================

      final responseData =
          await _flashSaleService.getFlashSaleById(flashSaleId);

      // =====================================================
      // RESPONSE DATA
      // =====================================================

      final rawData = responseData['data'] ?? responseData;

      if (rawData == null || rawData is! Map<String, dynamic>) {
        return;
      }

      // =====================================================
      // FLASH SALE MODEL
      // =====================================================

      final flashSale =
          FlashSaleModel.fromJson(rawData);

      flashSaleTitle.value = flashSale.title;

      final List<ProductModel> parsedProducts = [];

      // =====================================================
      // PARSE PRODUCTS
      // =====================================================

      for (final item in flashSale.products) {
        // ===================================================
        // CASE A:
        // Nested product object
        //
        // {
        //   product: {...},
        //   salePrice: 100,
        //   productType: "fresh",
        //   freshText: "2 hrs"
        // }
        // ===================================================

        if (item is Map) {
          if (item['product'] is Map) {
            final Map<String, dynamic> productMap =
                Map<String, dynamic>.from(
              item['product'] as Map,
            );

            // =================================================
            // PRODUCT TYPE
            // =================================================

            if (item['productType'] != null) {
              productMap['productType'] =
                  item['productType'];
            }

            // =================================================
            // FRESH TEXT
            // =================================================

            if (item['freshText'] != null) {
              productMap['freshText'] =
                  item['freshText'];
            }

            // =================================================
            // EXPIRY TEXT
            // =================================================

            if (item['expiryText'] != null) {
              productMap['expiryText'] =
                  item['expiryText'];
            }

            // =================================================
            // FLASH SALE PRICE
            // =================================================

            if (item['flashSalePrice'] != null ||
                item['salePrice'] != null) {
              productMap['flashSalePrice'] =
                  item['flashSalePrice'] ??
                      item['salePrice'];
            }

            // =================================================
            // CREATE PRODUCT MODEL
            // =================================================

            final product =
                ProductModel.fromJson(productMap);

            parsedProducts.add(product);

            // Debug
            print(
              '🔥 Flash Product: ${product.titleEn}',
            );

            print(
              '🔥 Product Type: ${product.productType}',
            );

            print(
              '🔥 Fresh Text: ${product.freshText}',
            );

            print(
              '🔥 Expiry Text: ${product.expiryText}',
            );

            print(
              '🔥 Flash Price: ${product.flashSalePrice}',
            );
          }

          // ===================================================
          // CASE B:
          // Direct product object
          //
          // {
          //   _id: "...",
          //   productType: "fresh",
          //   price: 100,
          //   ...
          // }
          // ===================================================

          else {
            final Map<String, dynamic> productMap =
                Map<String, dynamic>.from(item);

            final product =
                ProductModel.fromJson(productMap);

            parsedProducts.add(product);

            // Debug
            print(
              '🔥 Direct Flash Product: ${product.titleEn}',
            );

            print(
              '🔥 Product Type: ${product.productType}',
            );

            print(
              '🔥 Fresh Text: ${product.freshText}',
            );

            print(
              '🔥 Expiry Text: ${product.expiryText}',
            );
          }
        }

        // =====================================================
        // CASE C:
        // Product ID only
        // =====================================================

        else if (item is String) {
          if (Get.isRegistered<HomeController>()) {
            final homeController =
                Get.find<HomeController>();

            final matchedProduct =
                homeController.products.firstWhereOrNull(
              (product) => product.id == item,
            );

            if (matchedProduct != null) {
              parsedProducts.add(matchedProduct);

              print(
                '🔥 Matched Home Product: '
                '${matchedProduct.titleEn}',
              );

              print(
                '🔥 Product Type: '
                '${matchedProduct.productType}',
              );
            }
          }
        }
      }

      // =====================================================
      // LOCATION FILTER
      // =====================================================

      final String userLocationId =
          _getUserLocationId();

      if (userLocationId.isNotEmpty) {
        final List<ProductModel> filteredProducts =
            parsedProducts.where((product) {
          // যদি location না থাকে,
          // তাহলে সব location-এ দেখাবে
          if (product.locations.isEmpty) {
            return true;
          }

          // Location match
          return product.locations.any((location) {
            final String locationId =
                (location['_id'] ??
                        location['id'])
                    ?.toString() ??
                    "";

            return locationId == userLocationId;
          });
        }).toList();

        products.assignAll(filteredProducts);
      } else {
        products.assignAll(parsedProducts);
      }

      // =====================================================
      // FINAL DEBUG
      // =====================================================

      print(
        '🔥 Flash Sale ID: $flashSaleId',
      );

      print(
        '🔥 Flash Sale Title: ${flashSaleTitle.value}',
      );

      print(
        '🔥 Total Products: ${products.length}',
      );

      for (final product in products) {
        print(
          '🔥 ${product.titleEn} | '
          'Type: ${product.productType} | '
          'Fresh: ${product.freshText} | '
          'Expiry: ${product.expiryText}',
        );
      }
    } catch (e, stackTrace) {
      print(
        '❌ Error loading Flash Sale: $e',
      );

      print(
        '❌ StackTrace: $stackTrace',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // CLEAR DATA
  // =========================================================

  void clearFlashSale() {
    products.clear();
    flashSaleTitle.value = '';
  }
}