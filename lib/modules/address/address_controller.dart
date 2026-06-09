import 'package:get/get.dart';

import 'package:tin/data/models/address_model.dart';
import 'package:tin/data/services/address_service.dart';

class AddressController
    extends GetxController {

  final AddressService service =
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

  /// LOAD ADDRESSES
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

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value =
          false;
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

    try {

      isLoading.value =
          true;

      await service
          .createAddress({

        "fullName":
            fullName,

        "phoneNumber":
            phoneNumber,

        "areaOrVillage":
            areaOrVillage,

        "landmark":
            landmark,

        "directionNote":
            directionNote,

        "latitude":
            latitude,

        "longitude":
            longitude,

        "isDefault":
            isDefault,
      });

      await loadAddresses();

      Get.back();

      Get.snackbar(
        "Success",
        "Address Added Successfully",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value =
          false;
    }
  }

  /// DELETE ADDRESS
  Future<void> deleteAddress(
    String id,
  ) async {

    try {

      isLoading.value =
          true;

      await service
          .deleteAddress(
        id,
      );

      await loadAddresses();

      Get.snackbar(
        "Success",
        "Address Deleted",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value =
          false;
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

    try {

      isLoading.value =
          true;

      await service
          .updateAddress(
        id,
        {

          "fullName":
              fullName,

          "phoneNumber":
              phoneNumber,

          "areaOrVillage":
              areaOrVillage,

          "landmark":
              landmark,

          "directionNote":
              directionNote,

          "latitude":
              latitude,

          "longitude":
              longitude,

          "isDefault":
              isDefault,
        },
      );

      await loadAddresses();

      Get.back();

      Get.snackbar(
        "Success",
        "Address Updated",
      );

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value =
          false;
    }
  }

  /// SELECT ADDRESS
  void selectAddress(
    AddressModel address,
  ) {

    selectedAddress.value =
        address;
  }

  /// GET SELECTED ADDRESS ID
  String? get selectedAddressId {

    return selectedAddress
        .value
        ?.id;
  }
}