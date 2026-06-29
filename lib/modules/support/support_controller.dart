import 'package:get/get.dart';
import 'package:tin/data/models/support_model.dart';
import 'package:tin/data/services/support_service.dart';


class SupportController
    extends GetxController {
  final service = SupportService();

  RxBool isLoading = false.obs;

  Rxn<SupportLinkModel> support =
      Rxn<SupportLinkModel>();

  @override
  void onInit() {
    super.onInit();
    loadSupportLinks();
  }

  Future<void>
      loadSupportLinks() async {
    try {
      isLoading.value = true;

      final data =
          await service.getSupportLinks();

      support.value =
          SupportLinkModel.fromJson(
        data,
      );
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}