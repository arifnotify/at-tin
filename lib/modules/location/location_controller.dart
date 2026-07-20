import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tin/data/models/location_model.dart';
import 'package:tin/data/services/location_service.dart';

import 'package:tin/modules/home/home_controller.dart';



class LocationController extends GetxController {


  final LocationService service =
      LocationService();



  final GetStorage box =
      GetStorage();




  RxBool isLoading =
      false.obs;



  RxList<LocationModel> locations =
      <LocationModel>[].obs;




  RxString selectedDistrict =
      "".obs;



  RxString selectedDivision =
      "".obs;



  RxInt deliveryCharge =
      0.obs;






  @override
  void onInit() {

    super.onInit();


    loadFromCache();


    fetchLocations();


  }







  // =========================
  // LOCAL CACHE LOAD
  // =========================


  void loadFromCache() {


    selectedDistrict.value =
        box.read("locationDistrict") ?? "";



    selectedDivision.value =
        box.read("locationDivision") ?? "";



    deliveryCharge.value =
        box.read("deliveryCharge") ?? 0;


  }








  // =========================
  // FETCH LOCATIONS
  // =========================


  Future<void> fetchLocations() async {


    try {


      isLoading.value = true;




      final cached =
          box.read("locations");



      // CACHE FIRST

      if(cached != null){


        locations.value =
            (cached as List)
                .map(
                  (e)=>
                      LocationModel.fromJson(e),
                )
                .toList();


      }





      // API CALL


      final data =
          await service.getLocations();




      final parsed =
          data
              .map<LocationModel>(
                (e)=>
                    LocationModel.fromJson(e),
              )
              .where(
                (e)=>e.isActive,
              )
              .toList();




      locations.value =
          parsed;




      // SAVE CACHE


      box.write(
        "locations",
        data,
      );






      // AUTO SELECT FIRST LOCATION


      if(
        box.read("locationId")==null &&
        locations.isNotEmpty
      ){


        await selectLocation(
          locations.first,
        );


      }else{


        loadFromCache();


      }




    }catch(e){



      print(
        "Location Error : $e",
      );



      // FALLBACK CACHE


      final cached =
          box.read("locations");



      if(cached != null){


        locations.value =
            (cached as List)
                .map(
                  (e)=>
                      LocationModel.fromJson(e),
                )
                .toList();


      }



    }finally{


      isLoading.value =
          false;


    }


  }









  // =========================
  // SELECT LOCATION
  // =========================


  Future<void> selectLocation(
      LocationModel location,
  ) async {



    await box.write(
      "locationId",
      location.id,
    );



    await box.write(
      "locationDistrict",
      location.district,
    );



    await box.write(
      "locationDivision",
      location.division,
    );



    await box.write(
      "deliveryCharge",
      location.deliveryCharge,
    );




    selectedDistrict.value =
        location.district;



    selectedDivision.value =
        location.division;



    deliveryCharge.value =
        location.deliveryCharge;






    // =========================
    // RELOAD PRODUCTS
    // AFTER LOCATION CHANGE
    // =========================


    if(Get.isRegistered<HomeController>()){


      await Get.find<HomeController>()
          .changeLocationReload();


    }




  }








  // =========================
  // GET CURRENT LOCATION ID
  // =========================


  String get currentLocationId {


    return box.read(
      "locationId",
    ) ?? "";


  }








  // =========================
  // UI HELPER
  // =========================


  String get currentLocation {



    if(
      selectedDistrict.value.isNotEmpty
    ){

      return selectedDistrict.value;

    }




    if(locations.isNotEmpty){


      return locations.first.district;


    }





    return "Location";


  }




}