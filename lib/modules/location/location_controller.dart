import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/data/models/location_model.dart';
import 'package:tin/data/services/location_service.dart';


class LocationController extends GetxController {
  final LocationService service = LocationService();
  final GetStorage box = GetStorage();

  RxBool isLoading = false.obs;

  RxList<LocationModel> locations = <LocationModel>[].obs;

  RxString selectedDistrict = "".obs;
  RxString selectedDivision = "".obs;
  RxInt deliveryCharge = 0.obs;

  @override
  void onInit() {
    super.onInit();

    loadFromCache();      // 1️⃣ instant UI
    fetchLocations();     // 2️⃣ background sync
  }

  // =========================
  // LOCAL CACHE LOAD (FAST UI)
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
  // FETCH FROM API
  // =========================
  Future<void> fetchLocations() async {
    try {
      isLoading.value = true;

      final cached = box.read("locations");

      // 1️⃣ show cached first (instant)
      if (cached != null) {
        locations.value = (cached as List)
            .map((e) => LocationModel.fromJson(e))
            .toList();
      }

      // 2️⃣ get from API
      final data = await service.getLocations();

      final parsed = data
          .map<LocationModel>(
            (e) => LocationModel.fromJson(e),
          )
          .where((e) => e.isActive)
          .toList();

      locations.value = parsed;

      // 3️⃣ save cache
      box.write("locations", data);

      // 4️⃣ auto select first location
      if (box.read("locationId") == null &&
          locations.isNotEmpty) {
        await selectLocation(locations.first);
      } else {
        loadFromCache();
      }

    } catch (e) {
      // fallback cache
      final cached = box.read("locations");

      if (cached != null) {
        locations.value = (cached as List)
            .map((e) => LocationModel.fromJson(e))
            .toList();
      }

    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // SELECT LOCATION
  // =========================
  Future<void> selectLocation(LocationModel location) async {
    await box.write("locationId", location.id);
    await box.write("locationDistrict", location.district);
    await box.write("locationDivision", location.division);
    await box.write("deliveryCharge", location.deliveryCharge);

    selectedDistrict.value = location.district;
    selectedDivision.value = location.division;
    deliveryCharge.value = location.deliveryCharge;
  }

  // =========================
  // UI HELPER
  // =========================
  String get currentLocation {
    if (selectedDistrict.value.isNotEmpty) {
      return selectedDistrict.value;
    }

    if (locations.isNotEmpty) {
      return locations.first.district;
    }

    return "Location";
  }
}