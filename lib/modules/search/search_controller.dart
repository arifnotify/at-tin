import 'dart:async';

import 'package:get/get.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/search_service.dart';


class ProductSearchController
    extends GetxController {

  final SearchService service =
      SearchService();

  RxBool isLoading =
      false.obs;

  RxList<ProductModel>
      products =
      <ProductModel>[].obs;

  Timer? _debounce;

  String normalizeSearch(
    String text,
  ) {
    return text
        .trim()
        .toLowerCase();
  }

  void onSearchChanged(
    String value,
  ) {
    if (_debounce?.isActive ??
        false) {
      _debounce?.cancel();
    }

    _debounce = Timer(
      const Duration(
        milliseconds: 400,
      ),
      () {
        search(value);
      },
    );
  }

  Future<void> search(
    String text,
  ) async {

    final query =
        normalizeSearch(text);

    if (query.isEmpty) {
      products.clear();
      return;
    }

    try {

      isLoading.value =
          true;

      final data =
          await service
              .searchProducts(
        keyword: query,
      );

      final List list =
          data["products"] ??
              [];

      products.value =
          list
              .map<ProductModel>(
                (e) =>
                    ProductModel
                        .fromJson(
                  e,
                ),
              )
              .toList();

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value =
          false;
    }
  }

  @override
  void onClose() {

    _debounce?.cancel();

    super.onClose();
  }
}