import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tin/data/services/reward_service.dart';

class RewardController extends GetxController with WidgetsBindingObserver {
  final RewardService service = RewardService();

  /// ================= BALANCE =================
  var balance = 0.0.obs;
  var loading = false.obs;

  /// ================= TRANSACTIONS =================
  var transactions = <dynamic>[].obs;
  var txLoading = false.obs;

  // ব্যাকগ্রাউন্ড থেকে রেজুম হওয়ার সময় রি-ফেচ করার জন্য আইডি ও টোকেন সেভ রাখা
  String _lastUserId = "";
  String _lastToken = "";

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  // ==========================================================
  // 🔄 APP RESUME SYNC (ইউজার ২-৫ ঘণ্টা পর ব্যাকগ্রাউন্ড থেকে ফিরলে)
  // ==========================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastUserId.isNotEmpty) {
      print("⚡ REWARD: App resumed! Refreshing reward data...");
      loadRewardData(_lastUserId, _lastToken);
    }
  }

  // =========================
  // LOAD BALANCE
  // =========================
  Future<void> loadBalance(
    String userId,
    String token,
  ) async {
    _lastUserId = userId;
    _lastToken = token;

    try {
      loading.value = true;

      final result = await service.getWalletBalance(userId, token);

      // 💥 Safe Double Cast (ব্যাকএন্ড থেকে int পাঠালেও অ্যাপ ক্র্যাশ করবে না)
      if (result != null) {
        balance.value = (result as num).toDouble();
      }
    } catch (e) {
      print("Reward Balance Error: $e");
    } finally {
      loading.value = false;
    }
  }

  // =========================
  // LOAD TRANSACTIONS (Silent & Smooth Update)
  // =========================
  Future<void> loadTransactions(
    String userId,
    String token,
  ) async {
    _lastUserId = userId;
    _lastToken = token;

    try {
      // কেবল যদি মেমোরিতে আগে থেকে কোনো লিস্ট না থাকে, তখনই শুধু ফার্স্ট টাইম লোডার দেখাবে।
      if (transactions.isEmpty) {
        txLoading.value = true;
      }

      final result = await service.getTransactions(userId, token);

      /// 🔥 SAFE CAST & ASSIGN
      if (result is List) {
        transactions.assignAll(result);
      } else {
        transactions.clear();
      }
    } catch (e) {
      print("Reward Transaction Error: $e");
      if (transactions.isEmpty) {
        transactions.clear();
      }
    } finally {
      txLoading.value = false;
    }
  }

  // =========================
  // LOAD BOTH (BEST)
  // =========================
  Future<void> loadRewardData(
    String userId,
    String token,
  ) async {
    await Future.wait([
      loadBalance(userId, token),
      loadTransactions(userId, token),
    ]);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}