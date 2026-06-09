import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'address_controller.dart';
import 'pin_drop_screen.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({
    super.key,
  });

  @override
  State<AddAddressPage> createState() =>
      _AddAddressPageState();
}

class _AddAddressPageState
    extends State<AddAddressPage> {

  final fullNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final villageController =
      TextEditingController();

  final landmarkController =
      TextEditingController();

  final noteController =
      TextEditingController();

  bool isDefault = false;

  double? latitude;
  double? longitude;

  @override
  Widget build(
    BuildContext context,
  ) {

    final controller =
        Get.find<AddressController>();

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Add Address",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// FULL NAME
            TextField(
              controller:
                  fullNameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Full Name",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            /// PHONE
            TextField(
              controller:
                  phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText:
                    "Phone Number",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            /// VILLAGE / AREA
            TextField(
              controller:
                  villageController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Village / Area",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            /// LANDMARK
            TextField(
              controller:
                  landmarkController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Landmark",
                hintText:
                    "Mosque, School, Market",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            /// DIRECTION NOTE
            TextField(
              controller:
                  noteController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    "Direction Note",
                hintText:
                    "Red house beside pond",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /// LOCATION BUTTON
            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton.icon(

                icon: const Icon(
                  Icons.location_on,
                ),

                label: Text(

                  latitude == null

                      ? "Select Location"

                      : "Location Selected",
                ),

                onPressed:
                    () async {

                  final LatLng?
                      result =
                      await Get.to<
                          LatLng>(
                    () =>
                        const PinDropScreen(),
                  );

                  if (result !=
                      null) {

                    setState(() {

                      latitude =
                          result
                              .latitude;

                      longitude =
                          result
                              .longitude;
                    });
                  }
                },
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            /// SELECTED LOCATION INFO
            if (latitude != null)

              Container(

                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .all(
                  12,
                ),

                decoration:
                    BoxDecoration(

                  color: Colors
                      .green
                      .shade50,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    const Text(
                      "Selected Location",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      "Latitude: $latitude",
                    ),

                    Text(
                      "Longitude: $longitude",
                    ),
                  ],
                ),
              ),

            const SizedBox(
              height: 20,
            ),

            /// DEFAULT ADDRESS
            CheckboxListTile(

              value:
                  isDefault,

              contentPadding:
                  EdgeInsets.zero,

              onChanged:
                  (value) {

                setState(() {

                  isDefault =
                      value ??
                          false;
                });
              },

              title: const Text(
                "Set as Default Address",
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            /// SAVE BUTTON
            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(

                onPressed:
                    () async {

                  if (fullNameController
                      .text
                      .trim()
                      .isEmpty) {

                    Get.snackbar(
                      "Error",
                      "Enter Full Name",
                    );

                    return;
                  }

                  if (phoneController
                      .text
                      .trim()
                      .isEmpty) {

                    Get.snackbar(
                      "Error",
                      "Enter Phone Number",
                    );

                    return;
                  }

                  if (villageController
                      .text
                      .trim()
                      .isEmpty) {

                    Get.snackbar(
                      "Error",
                      "Enter Village / Area",
                    );

                    return;
                  }

                  if (landmarkController
                      .text
                      .trim()
                      .isEmpty) {

                    Get.snackbar(
                      "Error",
                      "Enter Landmark",
                    );

                    return;
                  }

                  if (latitude ==
                          null ||
                      longitude ==
                          null) {

                    Get.snackbar(
                      "Location Required",
                      "Please select your location",
                    );

                    return;
                  }

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

                    areaOrVillage:
                        villageController
                            .text
                            .trim(),

                    landmark:
                        landmarkController
                            .text
                            .trim(),

                    directionNote:
                        noteController
                            .text
                            .trim(),

                    latitude:
                        latitude!,

                    longitude:
                        longitude!,

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

  @override
  void dispose() {

    fullNameController.dispose();

    phoneController.dispose();

    villageController.dispose();

    landmarkController.dispose();

    noteController.dispose();

    super.dispose();
  }
}