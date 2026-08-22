import 'dart:async';
import 'package:get/get.dart';
import 'package:tin/core/constants/network_controller.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/data/services/search_service.dart';

class ProductSearchController extends GetxController {

  final SearchService service = SearchService();
  final SocketService socketService = SocketService();

  RxBool isLoading = false.obs;
  RxBool isUpdating = false.obs;
  RxList<ProductModel> products = <ProductModel>[].obs;

  Timer? _debounce;
  String currentKeyword = "";

  @override
  void onInit() {
    super.onInit();
    socketService.connect();

    socketService.listenProductUpdated((_) async {
      print("🔥 PRODUCT UPDATED FROM SOCKET");
      await refreshFromSocket();
    });
  }

  String normalizeSearch(String text) {
    return text.trim().toLowerCase();
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        search(value);
      },
    );
  }

  // ==========================
  // USER SEARCH
  // ==========================
  Future<void> search(String text) async {
    final query = normalizeSearch(text);
    currentKeyword = query;

    if (query.isEmpty) {
      products.clear();
      return;
    }

    // 🟢 ১. ইন্টারনেট চেক: কানেকশন না থাকলে NetworkController-এর স্ন্যাকবার দেখিয়ে রিটার্ন করবে
    if (Get.isRegistered<NetworkController>()) {
      final networkController = Get.find<NetworkController>();
      if (!networkController.isConnected.value) {
        networkController.showProfessionalSnackbar(
          isOffline: true,
          bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
          enMessage: "No internet connection detected",
        );
        return; // এপিআই কল আটকে দেবে
      }
    }

    try {
      isLoading.value = true;

      final data = await service.searchProducts(
        keyword: query,
      );

      updateProducts(data);

    } catch (e) {
      // 🟢 ২. যদি তাও কোনো ডায়নামিক নেটওয়ার্ক ড্রপের কারণে ক্যাচ ব্লকে আসে, তবে রাফ error না দেখিয়ে হ্যান্ডেল করা
      if (Get.isRegistered<NetworkController>()) {
        Get.find<NetworkController>().showProfessionalSnackbar(
          isOffline: true,
          bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
          enMessage: "No internet connection detected",
        );
      } else {
        Get.snackbar("Notice", "Network connection error");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // SOCKET BACKGROUND UPDATE
  // ==========================
  Future<void> refreshFromSocket() async {
    if (currentKeyword.isEmpty) return;

    // অফলাইনে থাকলে সকেট রিফ্রেশ রান হবে না
    if (Get.isRegistered<NetworkController>() && 
        !Get.find<NetworkController>().isConnected.value) {
      return;
    }

    try {
      isUpdating.value = true;

      final data = await service.searchProducts(
        keyword: currentKeyword,
      );

      updateProducts(data);

    } catch (e) {
      print("SOCKET REFRESH ERROR: $e");
    } finally {
      isUpdating.value = false;
    }
  }

  void updateProducts(dynamic data) {
    final List list = data["products"] ?? [];

    products.value = list
        .map<ProductModel>(
          (e) => ProductModel.fromJson(e),
        )
        .toList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}