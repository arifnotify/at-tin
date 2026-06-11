import 'package:get/get.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/services/category_service.dart';

class CategoryController extends GetxController {
  var isLoading = false.obs;
  var subCategories = <CategoryModel>[].obs;

  Future<void> loadSubCategories(String parentId) async {
    isLoading.value = true;

    final data =
        await CategoryService()
            .getSubCategories(parentId);

    subCategories.value = data;

    isLoading.value = false;
  }
}