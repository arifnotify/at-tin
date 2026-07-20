import 'package:get/get.dart';

import 'package:tin/core/socket/socket_service.dart';

import 'package:tin/data/models/banner_model.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/models/product_model.dart';

import 'package:tin/data/services/home_service.dart';

import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';



class HomeController extends GetxController {


  final HomeService service =
      HomeService();



  final SocketService socketService =
      SocketService();



  late LocationController locationController;




  RxBool isLoading =
      false.obs;


  RxBool isRefreshing =
      false.obs;




  RxList<BannerModel> banners =
      <BannerModel>[].obs;



  RxList<CategoryModel> categories =
      <CategoryModel>[].obs;



  RxList<ProductModel> products =
      <ProductModel>[].obs;







  @override
  void onInit() {


    super.onInit();



    print(
      "🏠 HOME CONTROLLER INIT",
    );



    // ==========================
    // LOCATION CONTROLLER
    // ==========================


    if(Get.isRegistered<LocationController>()){


      locationController =
          Get.find<LocationController>();


    }else{


      Get.put(
        LocationController(),
      );


      locationController =
          Get.find<LocationController>();

    }





    // ==========================
    // CART LOAD
    // ==========================


    if(Get.isRegistered<CartController>()){


      Get.find<CartController>()
          .loadServerCart();


    }






    // ==========================
    // FIRST HOME LOAD
    // ==========================


    loadHomeData();







    // ==========================
    // SOCKET CONNECT
    // ==========================


    socketService.connect();







    // ==========================
    // HOME UPDATE LISTENER
    // ==========================


socketService.listenHomeUpdated(
  (_) async {


    print(
      "🔥 HOME UPDATE RECEIVED",
    );


    // NO LOADER
    await loadHomeData(
      showLoader:false,
    );


  },
);


  }









  // ==========================
  // LOAD HOME DATA
  // ==========================


Future<void> loadHomeData({
  bool showLoader = true,
}) async {

  try {


    if(showLoader){
      isLoading.value = true;
    }



    // ==========================
    // BANNER
    // ==========================

    final bannerData =
        await service.getBanners();


    banners.assignAll(
      (bannerData as List)
          .map(
            (e)=>BannerModel.fromJson(e),
          )
          .toList(),
    );




    // ==========================
    // CATEGORY
    // ==========================


    final categoryData =
        await service.getMainCategories();



    categories.assignAll(
      (categoryData as List)
          .map(
            (e)=>CategoryModel.fromJson(e),
          )
          .toList(),
    );






    // ==========================
    // PRODUCTS
    // ==========================


    String? locationId;


    if(Get.isRegistered<LocationController>()){

      locationId =
          locationController.box.read(
            "locationId",
          );

    }



    final productData =
        await service.getProducts(
          locationId: locationId,
        );



    products.assignAll(

      (productData as List)
          .map(
            (e)=>ProductModel.fromJson(e),
          )
          .toList(),

    );




  }catch(e){


    print(
      "HOME LOAD ERROR $e",
    );


  }finally{


    if(showLoader){

      isLoading.value=false;

    }


  }

}








  // ==========================
  // LOCATION CHANGE
  // ==========================


  Future<void> changeLocationReload() async {



    isRefreshing.value = true;



    await loadHomeData();




    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );



    isRefreshing.value = false;



  }









  // ==========================
  // MANUAL REFRESH
  // ==========================


  Future<void> refreshHome() async {



    isRefreshing.value = true;




    await loadHomeData();




    await Future.delayed(
      const Duration(
        milliseconds: 800,
      ),
    );



    isRefreshing.value = false;



  }









@override
void onClose() {

  super.onClose();

}



}