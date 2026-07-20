import 'package:get/get.dart';
import 'package:tin/data/services/reward_service.dart';

class RewardController extends GetxController {
  final RewardService service = RewardService();

  /// ================= BALANCE =================
  var balance = 0.0.obs;
  var loading = false.obs;

  /// ================= TRANSACTIONS =================
  var transactions = <dynamic>[].obs;
  var txLoading = false.obs;

  // =========================
  // LOAD BALANCE
  // =========================
  Future<void> loadBalance(
    String userId,
    String token,
  ) async {
    try {
      loading.value = true;

      final result = await service.getWalletBalance(userId, token);
      balance.value = result;
    } catch (e) {
      print("Reward Balance Error: $e");
    } finally {
      loading.value = false;
    }
  }

  // =========================
  // LOAD TRANSACTIONS
  // =========================
  Future<void> loadTransactions(
    String userId,
    String token,
  ) async {
    try {
      txLoading.value = true;

      final result = await service.getTransactions(userId, token);

      /// 🔥 SAFE CAST (important)
      if (result is List) {
        transactions.value = result;
      } else {
        transactions.value = [];
      }

    } catch (e) {
      print("Reward Transaction Error: $e");
      transactions.value = [];
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
}