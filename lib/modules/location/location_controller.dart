import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/location_model.dart';
import 'package:tin/data/services/location_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'location_bottom_sheet.dart';

class LocationController extends GetxController {
  final LocationService service = LocationService();
  final SocketService socketService = SocketService();
  final GetStorage box = GetStorage();

  RxBool isLoading = false.obs;
  RxList<LocationModel> locations = <LocationModel>[].obs;

  RxString selectedDistrictEn = "".obs;
  RxString selectedDistrictBn = "".obs;
  RxString selectedDivisionEn = "".obs;
  RxString selectedDivisionBn = "".obs;
  RxInt deliveryCharge = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFromCache();
    fetchLocations();
    listenSocketEvents();
  }

  void listenSocketEvents() {
    socketService.listenLocationUpdated((_) async {
      print("📍 LOCATION UPDATED");
      await refreshLocations();
    });
  }

  Future<void> refreshLocations() async {
    try {
      final data = await service.getLocations();
      final parsed = data
          .map<LocationModel>((e) => LocationModel.fromJson(e))
          .where((e) => e.isActive)
          .toList();

      locations.value = parsed;
      await box.write("locations", data);

      await _applyLocationSelection();
    } catch (e) {
      print("Location Refresh Error: $e");
    }
  }

  // ==========================================
  // 1. LOCAL CACHE LOAD
  // ==========================================
  void loadFromCache() {
    selectedDistrictEn.value = box.read("locationDistrictEn") ?? "";
    selectedDistrictBn.value = box.read("locationDistrictBn") ?? "";
    selectedDivisionEn.value = box.read("locationDivisionEn") ?? "";
    selectedDivisionBn.value = box.read("locationDivisionBn") ?? "";
    deliveryCharge.value = box.read("deliveryCharge") ?? 0;
  }

  // ==========================================
  // 2. FETCH LOCATIONS FROM API & HANDLER
  // ==========================================
  Future<void> fetchLocations() async {
    try {
      isLoading.value = true;

      // ১. প্রথমে ক্যাশ থেকে ডাটা লোড করা
      final cached = box.read("locations");
      if (cached != null) {
        locations.value = (cached as List)
            .map((e) => LocationModel.fromJson(e))
            .where((e) => e.isActive)
            .toList();
      }

      // ২. নেটওয়ার্ক থেকে নতুন ডাটা ফেচ করা
      final data = await service.getLocations();
      final parsed = data
          .map<LocationModel>((e) => LocationModel.fromJson(e))
          .where((e) => e.isActive)
          .toList();

      locations.value = parsed;
      await box.write("locations", data);

    } catch (e) {
      print("Location Fetch Error: $e");
    } finally {
      isLoading.value = false;

      final bool hasSelected = box.read("hasSelectedLocation") ?? false;

      // ইউজার যদি আগে কখনো লোকেশন সিলেক্ট না করে থাকে
      if (!hasSelected && locations.isNotEmpty) {
        // UI ফ্রেম রেন্ডার শেষ হওয়ার পর পপআপ দেখানো নিশ্চিত করতে
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showFirstTimeLocationPopup();
        });
      } else {
        // যদি আগে থেকেই সিলেক্ট করা থাকে তবে আগের লোকেশন সেট করবে
        await _applyLocationSelection();
      }
    }
  }

  // ==========================================
  // HELPER: APPLY LOCATION SELECTION
  // ==========================================
  Future<void> _applyLocationSelection() async {
    if (locations.isEmpty) return;

    final String? savedLocationId = box.read("locationId");

    if (savedLocationId != null && savedLocationId.isNotEmpty) {
      final matched = locations.firstWhereOrNull((l) => l.id == savedLocationId);
      if (matched != null) {
        _updateLocalVariables(matched);
      } else {
        await selectLocation(locations.first);
      }
    } else {
      _updateLocalVariables(locations.first);
    }
  }

  void _updateLocalVariables(LocationModel location) {
    selectedDistrictEn.value = location.district.en;
    selectedDistrictBn.value = location.district.bn;
    selectedDivisionEn.value = location.division.en;
    selectedDivisionBn.value = location.division.bn;
    deliveryCharge.value = location.deliveryCharge;

    update();
  }

  // ==========================================
  // 3. FIRST TIME USER POPUP DIALOG
  // ==========================================
  void showFirstTimeLocationPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.deepPurple,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Your Location",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "সঠিক ডেলিভারি চার্জ এবং আপনার এলাকার ডিলগুলো দেখতে অনুগ্রহ করে আপনার লোকেশন সিলেক্ট করুন।",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.back();
                    Get.bottomSheet(
                      const LocationBottomSheet(),
                      isScrollControlled: true,
                    );
                  },
                  child: const Text(
                    "Choose Location",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ==========================================
  // 4. SELECT LOCATION ACTION
  // ==========================================
  Future<void> selectLocation(LocationModel location) async {
    await box.write("locationId", location.id);
    await box.write("locationDistrictEn", location.district.en);
    await box.write("locationDistrictBn", location.district.bn);
    await box.write("locationDivisionEn", location.division.en);
    await box.write("locationDivisionBn", location.division.bn);
    await box.write("deliveryCharge", location.deliveryCharge);
    await box.write("hasSelectedLocation", true);

    _updateLocalVariables(location);

    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().clearCart();
    }

    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().changeLocationReload();
    }
  }

  // ==========================================
  // GETTERS
  // ==========================================
  String get currentLocationId => box.read("locationId") ?? "";

  String getCurrentDistrict(bool isBangla) {
    if (isBangla) {
      if (selectedDistrictBn.value.isNotEmpty) return selectedDistrictBn.value;
    } else {
      if (selectedDistrictEn.value.isNotEmpty) return selectedDistrictEn.value;
    }
    if (locations.isNotEmpty) {
      return isBangla ? locations.first.district.bn : locations.first.district.en;
    }
    return "Location";
  }

  String get currentLocation {
    if (selectedDistrictEn.value.isNotEmpty) return selectedDistrictEn.value;
    if (locations.isNotEmpty) return locations.first.district.en;
    return "Location";
  }

  @override
  void onClose() {
    socketService.socket?.off('location_updated');
    super.onClose();
  }
}