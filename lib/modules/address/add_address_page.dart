import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'address_controller.dart';

class AddAddressPage
    extends StatefulWidget {

  const AddAddressPage({
    super.key,
  });

  @override
  State<AddAddressPage>
      createState() =>
          _AddAddressPageState();
}

class _AddAddressPageState
    extends State<
        AddAddressPage> {

  final fullNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final divisionController =
      TextEditingController();

  final districtController =
      TextEditingController();

  final areaController =
      TextEditingController();

  final addressController =
      TextEditingController();

  bool isDefault = false;

  @override
  Widget build(
      BuildContext context) {

    final controller =
        Get.find<AddressController>();

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
          "Add Address",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(

          children: [

            TextField(
              controller:
                  fullNameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Full Name",
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  phoneController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Phone Number",
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  divisionController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Division",
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  districtController,
              decoration:
                  const InputDecoration(
                labelText:
                    "District",
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  areaController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Area",
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
                  addressController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    "Address Line",
              ),
            ),

            CheckboxListTile(
              value:
                  isDefault,
              onChanged: (
                value,
              ) {

                setState(() {

                  isDefault =
                      value ??
                          false;
                });
              },
              title: const Text(
                "Default Address",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(

                onPressed:
                    () async {

                  await controller
                      .createAddress(

                    fullName:
                        fullNameController
                            .text
                            .trim(),

                    phoneNumber:
                        phoneController
                            .text
                            .trim(),

                    division:
                        divisionController
                            .text
                            .trim(),

                    district:
                        districtController
                            .text
                            .trim(),

                    area:
                        areaController
                            .text
                            .trim(),

                    addressLine:
                        addressController
                            .text
                            .trim(),

                    isDefault:
                        isDefault,
                  );
                },

                child:
                    const Text(
                  "Save Address",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}