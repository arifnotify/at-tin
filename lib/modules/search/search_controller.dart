import 'dart:async';

import 'package:get/get.dart';

import 'package:tin/core/socket/socket_service.dart';

import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/search_service.dart';



class ProductSearchController
    extends GetxController {



  final SearchService service =
      SearchService();



  final SocketService socketService =
      SocketService();




  // প্রথমবার user search করলে loader
  RxBool isLoading =
      false.obs;



  // Socket background update
  RxBool isUpdating =
      false.obs;




  RxList<ProductModel>
      products =
      <ProductModel>[].obs;




  Timer? _debounce;



  String currentKeyword = "";






  @override
  void onInit() {


    super.onInit();



    // ==========================
    // SOCKET CONNECT
    // ==========================

    socketService.connect();





    // ==========================
    // PRODUCT UPDATE LISTENER
    // ==========================

    socketService.listenProductUpdated(
      (_) async {


        print(
          "🔥 PRODUCT UPDATED FROM SOCKET",
        );



        await refreshFromSocket();



      },
    );



  }









  String normalizeSearch(
      String text,
      ){

    return text
        .trim()
        .toLowerCase();

  }









  void onSearchChanged(
      String value,
      ){



    if(_debounce?.isActive ?? false){

      _debounce!.cancel();

    }




    _debounce =
        Timer(
          const Duration(
            milliseconds:400,
          ),

          (){

            search(value);

          },

        );


  }









  // ==========================
  // USER SEARCH
  // ==========================


  Future<void> search(
      String text,
      ) async {



    final query =
    normalizeSearch(text);




    currentKeyword =
        query;





    if(query.isEmpty){


      products.clear();


      return;

    }







    try {



      // User action loader

      isLoading.value =
      true;





      final data =
      await service.searchProducts(

        keyword: query,

      );





      updateProducts(
        data,
      );







    }catch(e){


      Get.snackbar(
        "Error",
        e.toString(),
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



    if(currentKeyword.isEmpty){

      return;

    }




    try {



      // এখানে full loader হবে না

      isUpdating.value =
      true;





      final data =
      await service.searchProducts(

        keyword:
        currentKeyword,

      );





      updateProducts(
        data,
      );





    }catch(e){


      print(
        "SOCKET REFRESH ERROR: $e",
      );



    }finally{


      isUpdating.value =
      false;


    }



  }









  // ==========================
  // UPDATE PRODUCT LIST
  // ==========================


  void updateProducts(
      dynamic data,
      ){



    final List list =
        data["products"] ?? [];





    products.value =
        list
            .map<ProductModel>(

              (e)=>
                  ProductModel.fromJson(
                    e,
                  ),

            )

            .toList();



  }









  @override
  void onClose() {


    _debounce?.cancel();



    // IMPORTANT:
    // socket dispose করবেন না


    super.onClose();


  }



}