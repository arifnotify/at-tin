import 'package:get/get.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/services/category_service.dart';

class CategoryController extends GetxController {
  var isLoading = false.obs;

  var categories = <CategoryModel>[].obs;      // MAIN
  var subCategories = <CategoryModel>[].obs;   // SUB

  Future<void> loadMainCategories() async {
    isLoading.value = true;

    try {
      final data = await CategoryService().getMainCategories();

      categories.value =
          (data as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
    } catch (e) {
      print("ERROR: $e");
    }

    isLoading.value = false;
  }

  Future<void> loadSubCategories(String parentId) async {
    isLoading.value = true;

    try {
      final data = await CategoryService().getSubCategories(parentId);

      subCategories.value =
          (data as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
    } catch (e) {
      print("ERROR: $e");
    }

    isLoading.value = false;
  }
}