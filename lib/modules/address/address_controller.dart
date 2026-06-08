import 'package:get/get.dart';
import 'package:tin/data/models/address_model.dart';
import 'package:tin/data/services/address_service.dart';


class AddressController
    extends GetxController {

  final service =
      AddressService();

  RxBool isLoading =
      false.obs;

  RxList<AddressModel>
      addresses =
      <AddressModel>[].obs;

  Rx<AddressModel?>
      selectedAddress =
      Rx<AddressModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void>
      loadAddresses() async {

    try {

      isLoading.value =
          true;

      final data =
          await service
              .getAddresses();

      addresses.value =
          data
              .map<AddressModel>(
                (e) =>
                    AddressModel
                        .fromJson(
                  e,
                ),
              )
              .toList();

      if (addresses.isNotEmpty) {

        selectedAddress.value =
            addresses.firstWhere(
          (e) => e.isDefault,
          orElse:
              () =>
                  addresses.first,
        );
      }

    } finally {

      isLoading.value =
          false;
    }
  }

  Future<void> createAddress({

    required String fullName,

    required String phoneNumber,

    required String division,

    required String district,

    required String area,

    required String addressLine,

    required bool isDefault,

  }) async {

    try {

      await service.createAddress({

        "fullName":
            fullName,

        "phoneNumber":
            phoneNumber,

        "division":
            division,

        "district":
            district,

        "area":
            area,

        "addressLine":
            addressLine,

        "isDefault":
            isDefault,
      });

      await loadAddresses();

      Get.back();

      Get.snackbar(
        "Success",
        "Address Added",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  Future<void> deleteAddress(
    String id,
  ) async {

    await service.deleteAddress(
      id,
    );

    await loadAddresses();
  }

 void selectAddress(AddressModel address) {
  selectedAddress.value = address;
}
}