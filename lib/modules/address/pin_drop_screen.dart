import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class PinDropScreen extends StatefulWidget {
  const PinDropScreen({super.key});

  @override
  State<PinDropScreen> createState() =>
      _PinDropScreenState();
}

class _PinDropScreenState
    extends State<PinDropScreen> {

  final MapController mapController =
      MapController();

  LatLng selectedLocation =
      const LatLng(
    23.8103,
    90.4125,
  );

  bool isLoading = true;

  double currentZoom = 12;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void>
      _getCurrentLocation() async {

    try {

      LocationPermission permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
              LocationPermission
                  .denied ||
          permission ==
              LocationPermission
                  .deniedForever) {

        setState(() {
          isLoading = false;
        });

        return;
      }

      Position position =
          await Geolocator
              .getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      selectedLocation =
          LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void>
      _moveToCurrentLocation() async {

    Position position =
        await Geolocator
            .getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high,
    );

    final currentLocation =
        LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      selectedLocation =
          currentLocation;
    });

    mapController.move(
      currentLocation,
      16,
    );
  }

  void zoomIn() {

    currentZoom++;

    mapController.move(
      selectedLocation,
      currentZoom,
    );
  }

  void zoomOut() {

    currentZoom--;

    if (currentZoom < 5) {
      currentZoom = 5;
    }

    mapController.move(
      selectedLocation,
      currentZoom,
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Select Location",
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Stack(

              children: [

                FlutterMap(

                  mapController:
                      mapController,

                  options:
                      MapOptions(

                    initialCenter:
                        selectedLocation,

                    initialZoom: 12,

                    minZoom: 5,

                    maxZoom: 20,

                    onTap:
                        (
                      tapPosition,
                      point,
                    ) {

                      setState(() {

                        selectedLocation =
                            point;
                      });
                    },
                  ),

                  children: [

                    TileLayer(

                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName:
                          'com.tin.app',
                    ),

                    MarkerLayer(

                      markers: [

                        Marker(

                          point:
                              selectedLocation,

                          width: 60,

                          height: 60,

                          child:
                              const Icon(

                            Icons
                                .location_pin,

                            size: 50,

                            color:
                                Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                /// CURRENT LOCATION
                Positioned(

                  right: 15,

                  bottom: 220,

                  child:
                      FloatingActionButton(

                    heroTag:
                        "current",

                    mini: true,

                    onPressed:
                        _moveToCurrentLocation,

                    child:
                        const Icon(
                      Icons
                          .my_location,
                    ),
                  ),
                ),

                /// ZOOM IN
                Positioned(

                  right: 15,

                  bottom: 160,

                  child:
                      FloatingActionButton(

                    heroTag:
                        "zoomIn",

                    mini: true,

                    onPressed:
                        zoomIn,

                    child:
                        const Icon(
                      Icons.add,
                    ),
                  ),
                ),

                /// ZOOM OUT
                Positioned(

                  right: 15,

                  bottom: 100,

                  child:
                      FloatingActionButton(

                    heroTag:
                        "zoomOut",

                    mini: true,

                    onPressed:
                        zoomOut,

                    child:
                        const Icon(
                      Icons.remove,
                    ),
                  ),
                ),

                /// BOTTOM CARD
                Positioned(

                  left: 15,

                  right: 15,

                  bottom: 15,

                  child: Column(

                    children: [

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(
                          15,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),

                          boxShadow: const [

                            BoxShadow(
                              blurRadius:
                                  6,
                              color: Colors
                                  .black12,
                            ),
                          ],
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
                                    FontWeight.bold,
                                fontSize:
                                    16,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              "Latitude : ${selectedLocation.latitude}",
                            ),

                            Text(
                              "Longitude : ${selectedLocation.longitude}",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      SizedBox(

                        width:
                            double.infinity,

                        height: 55,

                        child:
                            ElevatedButton(

                          onPressed: () {

                            Get.back(
                              result:
                                  selectedLocation,
                            );
                          },

                          child:
                              const Text(
                            "Confirm Location",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}