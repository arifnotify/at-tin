import 'package:tin/core/network/dio_client.dart';

class CategoryService {

  Future<dynamic> getMainCategories() async {
    final res = await DioClient.dio.get("/categories/main");
    return res.data;
  }

  Future<dynamic> getSubCategories(String parentId) async {
    final res = await DioClient.dio.get(
      "/categories/subcategories/$parentId",
    );
    return res.data;
  }

Future<dynamic> getProductsByCategory(
  String categoryId,
  String locationId,
) async {


  final res =
  await DioClient.dio.get(

    "/categories/$categoryId/products",

    queryParameters: {

      "location": locationId,

    },

  );


  return res.data;

}
}