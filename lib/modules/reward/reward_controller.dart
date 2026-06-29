import 'package:get/get.dart';
import 'package:tin/data/services/reward_service.dart';
class RewardController extends GetxController {

  final RewardService service = RewardService();

  var balance = 0.0.obs;
  var loading = false.obs;

  Future<void> loadBalance(
    String userId,
    String token,
  ) async {

    try {
      loading.value = true;

      final result =
          await service.getWalletBalance(
        userId,
        token,
      );

      balance.value = result;

    } catch (e) {
      print("Reward Error: $e");
    } finally {
      loading.value = false;
    }
  }
}