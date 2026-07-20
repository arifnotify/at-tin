import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

import 'search_controller.dart';



class SearchScreen extends GetView<ProductSearchController> {


  SearchScreen({
    super.key,
  });



  final CartController cartController =
      Get.find<CartController>();




  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
          Colors.white,





      appBar: AppBar(


        elevation: 0,


        backgroundColor:
            Colors.white,


        foregroundColor:
            Colors.black,



        title: const Text(


          "Search Products",


          style: TextStyle(

            fontSize:18,

            fontWeight:
            FontWeight.w600,

          ),


        ),


      ),







      body:


      Column(


        children: [





          // ==========================
          // SEARCH FIELD
          // ==========================


          Padding(


            padding:
            const EdgeInsets.all(12),



            child:


            TextField(


              autofocus:true,



              decoration:


              InputDecoration(


                hintText:
                "Search in Bangla or English",



                prefixIcon:
                const Icon(
                  Icons.search,
                ),




                border:


                OutlineInputBorder(


                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),


                ),


              ),




              onChanged:


              controller.onSearchChanged,



            ),


          ),








          Expanded(


            child:


            Obx(() {





              // ==========================
              // FIRST SEARCH LOADING
              // ==========================


              if(controller
                  .isLoading
                  .value){



                return const Center(

                  child:
                  AppLoader(),

                );


              }







              // ==========================
              // EMPTY STATE
              // ==========================


              if(controller
                  .products
                  .isEmpty){



                return const Center(


                  child:


                  Text(

                    "Search products...",

                  ),


                );


              }








              // ==========================
              // PRODUCT GRID
              // ==========================


              return GridView.builder(



                padding:


                const EdgeInsets.symmetric(

                  horizontal:8,

                  vertical:12,

                ),




                itemCount:


                controller
                    .products
                    .length,







                gridDelegate:


                const SliverGridDelegateWithFixedCrossAxisCount(


                  crossAxisCount:3,


                  crossAxisSpacing:8,


                  mainAxisSpacing:10,


                  childAspectRatio:
                  0.50,


                ),







                itemBuilder:


                    (context,index){





                  final product =

                  controller
                      .products[index];







                  return ProductCard(


                    product:
                    product,


                  );



                },



              );






            }),


          ),



        ],


      ),







      bottomNavigationBar:


      AppBottomNavBar(


        cartController:
        cartController,


      ),



    );


  }



}