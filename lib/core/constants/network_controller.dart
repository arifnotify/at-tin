import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/search/search_controller.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    bool hasNoInternet = result.contains(ConnectivityResult.none);
    
    // 🟢 অ্যাপ শুরুর স্টেট ফিক্স: অফলাইন থাকলে শুরুতেই isConnected = false করে দেওয়া
    isConnected.value = !hasNoInternet;
    
    if (hasNoInternet) {
      showProfessionalSnackbar(
        isOffline: true,
        bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
        enMessage: "No internet connection detected",
      );
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    bool hasNoInternet = result.contains(ConnectivityResult.none);

    if (hasNoInternet) {
      if (isConnected.value) {
        isConnected.value = false;
        showProfessionalSnackbar(
          isOffline: true,
          bnMessage: "ইন্টারনেট কানেকশন বিচ্ছিন্ন রয়েছে!",
          enMessage: "No internet connection detected",
        );
      }
    } else {
      // 🟢 ইন্টারনেট অন হওয়ামাত্রই বা অফলাইন থেকে অনলাইনে এলে ফায়ার হবে
      if (!isConnected.value) {
        isConnected.value = true;
        
        showProfessionalSnackbar(
          isOffline: false,
          bnMessage: "ইন্টারনেট সংযোগ পুনরায় সক্রিয় হয়েছে",
          enMessage: "You are back online",
        );

        _onNetworkRestored();
      }
    }
  }

  /// ⚡ ইন্টারনেট ফিরে আসলে ইমেজ ক্যাশে ক্লিয়ার করবে ও ডাটা আনবে
/// ⚡ ইন্টারনেট ফিরে আসলে ইমেজ ক্যাশে ক্লিয়ার করবে ও ডাটা আনবে
  void _onNetworkRestored() {
    print("⚡ NETWORK RESTORED TRIGGERED");

    // 🟢 ১. Flutter-এর ব্যর্থ হওয়া ছবির ক্যাশে ক্লিয়ার করা
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 🟢 ২. HOME CONTROLLER REFRESH
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.socketService.connect();
      homeController.loadHomeData(showLoader: false);
    }

    // 🟢 ৩. CART CONTROLLER REFRESH
    if (Get.isRegistered<CartController>()) {
      final cartController = Get.find<CartController>();
      cartController.socketService.connect();
      cartController.loadServerCart();
    }

    // 🟢 ৪. PRODUCT SEARCH CONTROLLER REFRESH (নতুন যোগ করুন)
    if (Get.isRegistered<ProductSearchController>()) {
      final searchController = Get.find<ProductSearchController>();
      searchController.socketService.connect();
      if (searchController.currentKeyword.isNotEmpty) {
        searchController.search(searchController.currentKeyword);
      }
    }
  }

  // 💎 Premium UI Snackbar
  void showProfessionalSnackbar({
    required bool isOffline,
    required String bnMessage,
    required String enMessage,
  }) {
    final langController = Get.find<LanguageController>();
    final bool isBn = langController.currentLanguage.value == 'bn';

    final Color bgColor = isOffline ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final Color accentColor = isOffline ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final IconData iconData = isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded;

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      duration: Duration(seconds: isOffline ? 4 : 3),
      animationDuration: const Duration(milliseconds: 600),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInOutCubic,
      isDismissible: true,
      messageText: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOffline
                        ? (isBn ? "অফলাইন মোড" : "Offline Mode")
                        : (isBn ? "অনলাইন মোড" : "Online"),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBn ? bnMessage : enMessage,
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (Get.isSnackbarOpen) {
                  Get.closeCurrentSnackbar();
                }
              },
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}