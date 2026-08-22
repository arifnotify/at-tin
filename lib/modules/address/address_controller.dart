import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/data/models/address_model.dart';
import 'package:tin/data/services/address_service.dart';

class AddressController extends GetxController {
  final AddressService service = AddressService();
  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'cached_user_addresses';

  RxBool isLoading = false.obs;
  RxList<AddressModel> addresses = <AddressModel>[].obs;
  Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // ১. অ্যাপ চালু হওয়ার সাথে সাথে লোকাল স্টোরেজ থেকে ডাটা লোড হবে (Instant UI)
    _loadFromLocalStorage();
    // ২. ব্যাকগ্রাউন্ডে বা ফার্স্ট টাইম সার্ভার থেকে আপডেট ডাটা ফেচ করবে
    loadAddresses();
  }

  // =========================
  // LOCAL STORAGE HANDLERS
  // =========================
  
  /// লোকাল ডিকশনারি থেকে ডাটা রিড করা
  void _loadFromLocalStorage() {
    try {
      final storedData = _storage.read<List>(_storageKey);
      if (storedData != null && storedData.isNotEmpty) {
        final List<AddressModel> cachedList = storedData
            .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        addresses.assignAll(cachedList);
        _syncSelectedAddress();
      }
    } catch (e) {
      print("Error loading addresses from local storage: $e");
    }
  }

  /// লোকাল ডিকশনারিতে ডাটা রাইট/সেভ করা
  void _saveToLocalStorage() {
    try {
      final List<Map<String, dynamic>> jsonList =
          addresses.map((e) => e.toJson()).toList();
      _storage.write(_storageKey, jsonList);
    } catch (e) {
      print("Error saving addresses to local storage: $e");
    }
  }

  // =========================
  // HELPER: NETWORK CHECK
  // =========================
  bool _checkInternetConnection() {
    if (Get.isRegistered<NetworkController>()) {
      final network = Get.find<NetworkController>();
      if (!network.isConnected.value) {
        network.showProfessionalSnackbar(
          isOffline: true,
          bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
          enMessage: "No internet connection detected",
        );
        return false;
      }
    }
    return true;
  }

  /// LOAD ADDRESSES (Fetch from Server & Cache Locally)
  /// forceRefresh = true দিলে (যেমন: Pull to Refresh) লোডিং স্পিনার দেখাবে
  Future<void> loadAddresses({bool forceRefresh = false}) async {
    // যদি লোকালি ডাটা না থাকে কেবল তখনই লোডিং স্পিনার দেখাবো
    if (addresses.isEmpty || forceRefresh) {
      isLoading.value = true;
    }

    if (!_checkInternetConnection()) {
      isLoading.value = false;
      return;
    }

    try {
      final data = await service.getAddresses();

      if (data is List) {
        final List<AddressModel> parsedList = data
            .map<AddressModel>((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        addresses.assignAll(parsedList);
        _saveToLocalStorage(); // 🔹 সার্ভারের নতুন ডাটা লোকালি সেভ করা হলো
      } else {
        addresses.clear();
        _storage.remove(_storageKey);
      }

      _syncSelectedAddress();
    } catch (e) {
      print("Error loading addresses: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// CREATE ADDRESS
  Future<void> createAddress({
    required String fullName,
    required String phoneNumber,
    required String areaOrVillage,
    required String landmark,
    String? directionNote,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    if (!_checkInternetConnection()) return;

    try {
      isLoading.value = true;

      final response = await service.createAddress({
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "areaOrVillage": areaOrVillage,
        "landmark": landmark,
        "directionNote": directionNote,
        "latitude": latitude,
        "longitude": longitude,
        "isDefault": isDefault,
      });

      if (response != null) {
        final newAddress = AddressModel.fromJson(Map<String, dynamic>.from(response));

        if (newAddress.isDefault) {
          _resetDefaultAddress();
        }

        addresses.add(newAddress);
        selectedAddress.value = newAddress;
        _saveToLocalStorage(); // 🔹 লোকাল ক্যাশ আপডেট
      }

      Get.back();
      Get.snackbar("Success", "Address Added Successfully");
    } catch (e) {
      print("Error creating address: $e");
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE ADDRESS
  Future<void> updateAddress({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String areaOrVillage,
    required String landmark,
    String? directionNote,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    if (!_checkInternetConnection()) return;

    try {
      isLoading.value = true;

      final response = await service.updateAddress(id, {
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "areaOrVillage": areaOrVillage,
        "landmark": landmark,
        "directionNote": directionNote,
        "latitude": latitude,
        "longitude": longitude,
        "isDefault": isDefault,
      });

      final index = addresses.indexWhere((e) => e.id == id);
      if (index != -1) {
        if (isDefault) {
          _resetDefaultAddress();
        }

        final updatedAddress = response != null
            ? AddressModel.fromJson(Map<String, dynamic>.from(response))
            : addresses[index].copyWith(
                fullName: fullName,
                phoneNumber: phoneNumber,
                areaOrVillage: areaOrVillage,
                landmark: landmark,
                directionNote: directionNote,
                latitude: latitude,
                longitude: longitude,
                isDefault: isDefault,
              );

        addresses[index] = updatedAddress;

        if (selectedAddress.value?.id == id) {
          selectedAddress.value = updatedAddress;
        }

        _saveToLocalStorage(); // 🔹 লোকাল ক্যাশ আপডেট
      }

      Get.back();
      Get.snackbar("Success", "Address Updated");
    } catch (e) {
      print("Error updating address: $e");
      Get.snackbar("Error", "Failed to update address.");
    } finally {
      isLoading.value = false;
    }
  }

  /// DELETE ADDRESS
  Future<void> deleteAddress(String id) async {
    if (!_checkInternetConnection()) return;

    try {
      isLoading.value = true;
      await service.deleteAddress(id);

      addresses.removeWhere((e) => e.id == id);

      if (selectedAddress.value?.id == id) {
        _syncSelectedAddress();
      }

      _saveToLocalStorage(); // 🔹 লোকাল ক্যাশ আপডেট

      Get.snackbar("Success", "Address Deleted");
    } catch (e) {
      print("Error deleting address: $e");
      Get.snackbar("Error", "Failed to delete address.");
    } finally {
      isLoading.value = false;
    }
  }

  /// SELECT ADDRESS
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  /// GET SELECTED ADDRESS ID
  String? get selectedAddressId => selectedAddress.value?.id;

  // =========================
  // HELPER METHODS
  // =========================
  void _resetDefaultAddress() {
    for (int i = 0; i < addresses.length; i++) {
      if (addresses[i].isDefault) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
    }
  }

  void _syncSelectedAddress() {
    if (addresses.isNotEmpty) {
      final currentSelectedId = selectedAddress.value?.id;
      final exists = addresses.firstWhereOrNull((e) => e.id == currentSelectedId);

      if (exists != null) {
        selectedAddress.value = exists;
      } else {
        selectedAddress.value = addresses.firstWhere(
          (e) => e.isDefault,
          orElse: () => addresses.first,
        );
      }
    } else {
      selectedAddress.value = null;
    }
  }

  /// ইউজার লগআউট করলে এই মেথড কল করে লোকাল অ্যাড্রেস ক্যাশ মুছে ফেলুন
  void clearLocalCache() {
    addresses.clear();
    selectedAddress.value = null;
    _storage.remove(_storageKey);
  }
}