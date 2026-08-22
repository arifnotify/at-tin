import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tin/core/socket/socket_service.dart';
import 'package:tin/data/services/auth_service.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/order/order_controller.dart';
import 'package:tin/modules/order/order_tracking_controller.dart';
import 'package:tin/controller/language_controller.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  final service = AuthService();
  final box = GetStorage();
  final SocketService _socketService = SocketService();

  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  /// 🔥 USER DATA STORE
  RxMap<String, dynamic> user = <String, dynamic>{}.obs;

  // ডায়ালগ যেন বারবার একই সাথে না খোলে তার ফ্ল্যাগ
  bool _isBlockDialogOpen = false;
  bool _isSocketInitialized = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // ব্যাকগ্রাউন্ড ট্র্যাকিং
    checkLogin();
  }

  // ==========================================================
  // 🔄 APP RESUME SYNC (অ্যাপ ব্যাকগ্রাউন্ড থেকে ফিরলে)
  // ==========================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isLoggedIn.value) {
      print("⚡ AUTH: App resumed! Re-checking profile & socket connection...");
      _initUserSocket();
      fetchFreshProfile();
    }
  }

  // =========================
  // CHECK LOGIN & BLOCK STATUS
  // =========================
  Future<void> checkLogin() async {
    final token = box.read("token");
    final savedUser = box.read("user_data");

    isLoggedIn.value = token != null;

    if (isLoggedIn.value) {
      if (savedUser != null) {
        user.value = Map<String, dynamic>.from(savedUser);

        // ⛔ ১. লোকাল ডাটাতে ব্লকড কিনা চেক
        if (user['isBlocked'] == true) {
          _showBlockedDialogAndLogout(user['blockReason']);
          return;
        }
      }

      // 🔌 সকেট কানেক্ট ও ইউজার রুমে জয়েন
      _initUserSocket();

      // ⛔ ২. সার্ভার থেকে ফ্রেশ ডাটা এনে ব্লক চেক
      await fetchFreshProfile();

      // ইউজার এখনও ভ্যালিড থাকলে কার্ট ও ব্যাকএন্ড ডাটা লোড
      if (isLoggedIn.value) {
        if (Get.isRegistered<CartController>()) {
          await Get.find<CartController>().loadServerCart();
        }

        if (Get.isRegistered<OrderController>()) {
          final orderCtrl = Get.find<OrderController>();
          await orderCtrl.loadActiveOrders();
          await orderCtrl.loadRewardWallet();
        }
      }
    }
  }

  // ==========================================================
  // FETCH FRESH PROFILE FROM SERVER
  // ==========================================================
  Future<void> fetchFreshProfile() async {
    try {
      final freshUser = await service.getProfile();
      if (freshUser != null) {
        user.value = Map<String, dynamic>.from(freshUser);
        box.write("user_data", freshUser);

        // ⛔ ইউজার ব্লকড থাকলে ডায়ালগ দেখাবে
        if (freshUser['isBlocked'] == true) {
          _showBlockedDialogAndLogout(freshUser['blockReason']);
        }
      }
    } catch (e) {
      print("PROFILE FETCH ERROR: $e");
    }
  }

  // ==========================================================
  // 🔌 SOCKET CONNECT & LISTENERS
  // ==========================================================
  void _initUserSocket() {
    final userId = user['_id'] ?? user['id'];

    if (userId != null && userId.toString().isNotEmpty) {
      _socketService.connect();

      // ১. সকেটের নির্দিষ্ট ইউজার রুমে জয়েন করা
      _socketService.socket?.emit('join_user', userId.toString());

      // ডুপ্লিকেট লিসেনার এড়াতে ফ্ল্যাগ চেক
      if (_isSocketInitialized) return;
      _isSocketInitialized = true;

      // ২. রিয়েল-টাইমে ইউজার ব্লক হলে লিসেন করা
      _socketService.listenUserBlockStatus((data) {
        if (data != null && data['isBlocked'] == true) {
          _showBlockedDialogAndLogout(data['reason']);
        }
      });

      // ৩. ইউজার প্রোফাইল / পয়েন্ট / টাইপ আপডেট লিসেন করা
      _socketService.listenUserUpdated((data) {
        print("🔥 SOCKET: USER DATA UPDATED => $data");

        if (data != null && data['data'] != null) {
          Map<String, dynamic> updatedFields =
              Map<String, dynamic>.from(data['data']);

          user.addAll(updatedFields);
          user.refresh();

          box.write("user_data", user.value);

          if (user['isBlocked'] == true) {
            _showBlockedDialogAndLogout(user['blockReason']);
            return;
          }

          if (Get.isRegistered<OrderController>()) {
            Get.find<OrderController>().loadRewardWallet();
          }
        }
      });
    }
  }

  // ==========================================================
  // ⛔ BLOCK DIALOG & FORCE LOGOUT (SAFE SINGLE DIALOG)
  // ==========================================================
  void _showBlockedDialogAndLogout([String? reason]) {
    if (_isBlockDialogOpen) return; // ডায়ালগ অলরেডি খোলা থাকলে নতুন করে খুলবে না
    _isBlockDialogOpen = true;

    bool isBn = true;
    if (Get.isRegistered<LanguageController>()) {
      isBn = Get.find<LanguageController>().isBangla;
    }

    String blockReason = reason ??
        (isBn
            ? 'আপনার অ্যাকাউন্টটি স্থগিত বা ব্লক করা হয়েছে। যেকোনো সহায়তার জন্য সাপোর্ট সেন্টারে যোগাযোগ করুন।'
            : 'Your account has been suspended or blocked. Please contact support.');

    Get.defaultDialog(
      title: isBn ? "অ্যাকাউন্ট স্থগিত!" : "Account Blocked!",
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      middleText: blockReason,
      barrierDismissible: false,
      textConfirm: isBn ? "ঠিক আছে" : "OK",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _isBlockDialogOpen = false;
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        logout();
      },
    );
  }

  // =========================
  // SEND OTP
  // =========================
  Future<void> sendOtp(String phone) async {
    bool isBn = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>().isBangla
        : true;

    try {
      isLoading.value = true;
      await service.sendOtp(phone);
      Get.toNamed("/otp", arguments: phone);
    } catch (e) {
      Get.snackbar(
        isBn ? "সংযোগ ত্রুটি" : "Connection Error",
        isBn
            ? "সার্ভারের সাথে সংযোগ স্থাপন করা যাচ্ছে না। আপনার মোবাইল নাম্বার ঠিক আছে ?"
            : "Could not connect to the server. Please check your number",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // VERIFY OTP
  // =========================
  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    bool isBn = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>().isBangla
        : true;

    try {
      isLoading.value = true;

      final data = await service.verifyOtp(phone: phone, otp: otp);
      final userData = data["user"] ?? {};

      if (userData['isBlocked'] == true) {
        _showBlockedDialogAndLogout(userData['blockReason']);
        return;
      }

      box.write("token", data["token"] ?? data["access_token"]);
      user.value = Map<String, dynamic>.from(userData);
      box.write("user_data", userData);

      isLoggedIn.value = true;

      _initUserSocket();

      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().syncCartAfterLogin();
      }

      if (Get.isRegistered<OrderController>()) {
        final orderCtrl = Get.find<OrderController>();
        await orderCtrl.loadActiveOrders();
        await orderCtrl.loadRewardWallet();
      }

      Get.offAllNamed("/home");
    } catch (e) {
      Get.snackbar(
        isBn ? "যাচাইকরণ ব্যর্থ হয়েছে" : "Verification Failed",
        isBn
            ? "ভুল ওটিপি অথবা সার্ভার সমস্যা! দয়া করে সঠিক ওটিপি দিয়ে আবার চেষ্টা করুন।"
            : "Incorrect OTP or server issue! Please try again with the correct OTP.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  void logout() {
    _isSocketInitialized = false;
    box.remove("token");
    box.remove("user_data");
    user.clear();

    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearCart();
    }

    if (Get.isRegistered<OrderController>()) {
      final order = Get.find<OrderController>();
      order.activeOrders.clear();
      order.selectedOrderId.value = "";
      order.hasActiveOrder.value = false;
      order.trackingEnabled.value = false;
      order.showTrackingBar.value = false;
      order.activeOrderStatus = null;
      order.trackingProgress.value = 0;
      order.isTrackingMinimized.value = true;
    }

    if (Get.isRegistered<OrderTrackingController>()) {
      final tracking = Get.find<OrderTrackingController>();
      tracking.stopTracking();
      tracking.status.value = "";
      tracking.trackingEnabled.value = false;
      tracking.isLoading.value = false;
      tracking.etaText.value = "-- min";
      tracking.riderLat.value = 0;
      tracking.riderLng.value = 0;
      tracking.destLat.value = 0;
      tracking.destLng.value = 0;
      tracking.progress.value = 0;
    }

    isLoggedIn.value = false;
    _socketService.disconnect();

    Get.offAllNamed("/home");
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}