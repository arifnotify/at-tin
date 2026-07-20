import 'package:tin/core/network/dio_client.dart';

class HomeService {

  // =========================
  // BANNERS
  // =========================

  Future<dynamic> getBanners() async {
    final response =
        await DioClient.dio.get(
      "/banners",
    );

    return response.data;
  }


  // =========================
  // MAIN CATEGORIES
  // =========================

  Future<dynamic> getMainCategories() async {
    final response =
        await DioClient.dio.get(
      "/categories/main",
    );

    return response.data;
  }


  // =========================
  // ALL CATEGORIES
  // =========================

  Future<dynamic> getCategories() async {
    final response =
        await DioClient.dio.get(
      "/categories",
    );

    return response.data;
  }



  // =========================
  // PRODUCTS BY LOCATION
  // =========================

  Future<dynamic> getProducts({
    String? locationId,
    String? search,
  }) async {


    final Map<String,dynamic> query = {};


    // LOCATION FILTER

    if(locationId != null &&
       locationId.isNotEmpty){

      query['location'] = locationId;

    }


    // SEARCH FILTER

    if(search != null &&
       search.isNotEmpty){

      query['search'] = search;

    }



    final response =
        await DioClient.dio.get(
      "/products",
      queryParameters: query,
    );


    return response.data;
  }



  // =========================
  // SEARCH PRODUCTS
  // =========================

  Future<dynamic> searchProducts({
    String? keyword,
    String? category,
    String? location,
    String? minPrice,
    String? maxPrice,
    String? sort,
    String? page,
    String? limit,
  }) async {


    final response =
        await DioClient.dio.get(
      "/products/search",
      queryParameters: {

        if(keyword != null)
          "keyword": keyword,


        if(category != null)
          "category": category,


        if(location != null)
          "location": location,


        if(minPrice != null)
          "minPrice": minPrice,


        if(maxPrice != null)
          "maxPrice": maxPrice,


        if(sort != null)
          "sort": sort,


        if(page != null)
          "page": page,


        if(limit != null)
          "limit": limit,

      },
    );


    return response.data;
  }



}