import 'package:get/get.dart';

import 'package:tin/core/socket/socket_service.dart';

import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/category_service.dart';

import 'package:tin/modules/location/location_controller.dart';



class ProductsController extends GetxController {


  final CategoryService service =
      CategoryService();



  final SocketService socketService =
      SocketService();



  final LocationController locationController =
      Get.find<LocationController>();




  // ==========================
  // PRODUCTS
  // ==========================

  RxList<ProductModel> products =
      <ProductModel>[].obs;



  // First loading
  RxBool isLoading =
      false.obs;



  // Background socket update
  RxBool isRefreshing =
      false.obs;




  late String categoryId;

  late String locationId;





  @override
  void onInit() {


    super.onInit();



    final Map args =
        Get.arguments ?? {};



    categoryId =
        args["_id"] ?? "";



    locationId =
        locationController.box.read(
          "locationId",
        ) ?? "";




    loadProducts();



    initSocket();



  }









  // ==========================
  // FIRST LOAD
  // ==========================


  Future<void> loadProducts() async {


    try {


      isLoading.value = true;



      final data =
      await service.getProductsByCategory(

        categoryId,

        locationId,

      );




      updateProducts(data);




    }catch(e){


      print(
        "PRODUCT LOAD ERROR => $e",
      );



    }finally{


      isLoading.value =
          false;


    }



  }









  // ==========================
  // SOCKET BACKGROUND UPDATE
  // ==========================


  Future<void> refreshFromSocket()
  async {



    try {



      // এখানে full loader হবে না

      isRefreshing.value =
          true;




      final data =
      await service.getProductsByCategory(

        categoryId,

        locationId,

      );




      updateProducts(data);




    }catch(e){


      print(
        "SOCKET PRODUCT ERROR => $e",
      );


    }finally{


      isRefreshing.value =
          false;


    }



  }









  // ==========================
  // UPDATE LIST
  // ==========================


  void updateProducts(
      dynamic data,
      ){



    products.assignAll(


      (data as List)

          .map(

            (e)=>

            ProductModel.fromJson(
              e,
            ),

      )

          .toList(),


    );


  }









  // ==========================
  // SOCKET INIT
  // ==========================


  void initSocket(){



    socketService.connect();




    socketService.listenProductUpdated(

          (_) {


        print(
          "🔥 PRODUCT PAGE SOCKET UPDATE",
        );



        refreshFromSocket();



      },


    );



  }










  // ==========================
  // LOCATION CHANGE
  // ==========================


  Future<void> changeLocation(
      String newLocationId,
      ) async {


    locationId =
        newLocationId;



    await loadProducts();



  }








  @override
  void onClose(){


    super.onClose();


  }



}