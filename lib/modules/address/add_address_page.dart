import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:tin/data/models/address_model.dart';
import 'address_controller.dart';

class AddAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddAddressPage({super.key, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final villageController = TextEditingController();
  final landmarkController = TextEditingController();
  final noteController = TextEditingController();

  bool isDefault = false;
  LatLng? selectedLocation;

  final MapController _mapController = MapController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      fullNameController.text = widget.address!.fullName;
      phoneController.text = widget.address!.phoneNumber;
      villageController.text = widget.address!.areaOrVillage;
      landmarkController.text = widget.address!.landmark;
      noteController.text = widget.address!.directionNote ?? '';

      selectedLocation = LatLng(
        widget.address!.latitude,
        widget.address!.longitude,
      );
      isDefault = widget.address!.isDefault;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(selectedLocation!, 15);
    } catch (e) {
      print("Initial location error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar("Permission Denied", "Please allow location permission from settings");
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location Off", "Please turn on GPS");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() => selectedLocation = newLocation);
      _mapController.move(newLocation, 16);
    } catch (e) {
      Get.snackbar("Failed", "Could not get current location. Tap on map manually.");
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? "Add New Address" : "Edit Address"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(fullNameController, "Full Name", Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(phoneController, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField(villageController, "Village / Area", Icons.location_city),
                    const SizedBox(height: 16),
                    _buildTextField(landmarkController, "Landmark", Icons.landscape, hint: "Mosque, School, Market etc."),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text("Select Location on Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: selectedLocation ?? const LatLng(23.6850, 90.3563),
                                initialZoom: 15,
                                minZoom: 5,
                                maxZoom: 20,
                                onTap: (tapPosition, point) {
                                  setState(() => selectedLocation = point);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.tin.app',
                                ),
                                if (selectedLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: selectedLocation!,
                                        width: 60,
                                        height: 60,
                                        child: const Icon(Icons.location_pin, size: 50, color: Colors.red),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Floating Buttons
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Column(
                                children: [
                                  FloatingActionButton(
                                    mini: true,
                                    heroTag: "current",
                                    onPressed: _moveToCurrentLocation,
                                    child: const Icon(Icons.my_location, size: 20),
                                  ),
                                  const SizedBox(height: 6),
                                  FloatingActionButton(
                                    mini: true,
                                    heroTag: "zoomIn",
                                    onPressed: _zoomIn,
                                    child: const Icon(Icons.add, size: 20),
                                  ),
                                  const SizedBox(height: 6),
                                  FloatingActionButton(
                                    mini: true,
                                    heroTag: "zoomOut",
                                    onPressed: _zoomOut,
                                    child: const Icon(Icons.remove, size: 20),
                                  ),
                                ],
                              ),
                            ),

                            if (isLoading) const Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (selectedLocation != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Selected Location", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text("Lat: ${selectedLocation!.latitude.toStringAsFixed(6)}"),
                            Text("Lng: ${selectedLocation!.longitude.toStringAsFixed(6)}"),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTextField(noteController, "Direction Note (Optional)", Icons.note, maxLines: 3),
              ),
            ),

            const SizedBox(height: 16),

            CheckboxListTile(
              value: isDefault,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) => setState(() => isDefault = value ?? false),
              title: const Text("Set as Default Address"),
              activeColor: Colors.blue,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // আগের সেভ লজিক (আপনার কন্ট্রোলার অনুযায়ী রাখুন)
                  if (fullNameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      villageController.text.trim().isEmpty ||
                      landmarkController.text.trim().isEmpty) {
                    Get.snackbar("Error", "Please fill all fields");
                    return;
                  }

                  if (selectedLocation == null) {
                    Get.snackbar("Error", "Please select location on map");
                    return;
                  }

                  final controller = Get.find<AddressController>();

                  if (widget.address == null) {
                    await controller.createAddress(
                      fullName: fullNameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      areaOrVillage: villageController.text.trim(),
                      landmark: landmarkController.text.trim(),
                      directionNote: noteController.text.trim(),
                      latitude: selectedLocation!.latitude,
                      longitude: selectedLocation!.longitude,
                      isDefault: isDefault,
                    );
                  } else {
                    await controller.updateAddress(
                      id: widget.address!.id,
                      fullName: fullNameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      areaOrVillage: villageController.text.trim(),
                      landmark: landmarkController.text.trim(),
                      directionNote: noteController.text.trim(),
                      latitude: selectedLocation!.latitude,
                      longitude: selectedLocation!.longitude,
                      isDefault: isDefault,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  widget.address == null ? "Save Address" : "Update Address",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
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
    _mapController.dispose();
    super.dispose();
  }
}