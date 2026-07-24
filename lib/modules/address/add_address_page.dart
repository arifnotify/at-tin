import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:tin/controller/language_controller.dart';

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

  // Language & Address Controllers
  final lang = Get.isRegistered<LanguageController>()
      ? Get.find<LanguageController>()
      : Get.put(LanguageController());

  // Brand Theme Colors
  final Color bgCream = const Color(0xFFF7F4EB);
  final Color cardColor = const Color(0xFFFCFAF2);
  final Color accentGold = const Color(0xFFD4AF37);
  final Color darkGreen = const Color(0xFF1D4D33);
  final Color textDark = const Color(0xFF2C2520);

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
      debugPrint("Initial location error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
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
        Get.snackbar(
          lang.isBangla ? "অনুমতি দেওয়া হয়নি" : "Permission Denied",
          lang.isBangla ? "সেটিংস থেকে লোকেশন পারমিশন দিন" : "Please allow location permission from settings",
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          lang.isBangla ? "জিপিএস বন্ধ" : "Location Off",
          lang.isBangla ? "দয়া করে জিপিএস চালু করুন" : "Please turn on GPS",
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() => selectedLocation = newLocation);
      _mapController.move(newLocation, 16);
    } catch (e) {
      Get.snackbar(
        lang.isBangla ? "ব্যর্থ হয়েছে" : "Failed",
        lang.isBangla ? "বর্তমান লোকেশন পাওয়া যায়নি। ম্যাপে ম্যানুয়ালি ক্লিক করুন।" : "Could not get current location. Tap on map manually.",
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          widget.address == null
              ? (lang.isBangla ? "নতুন ঠিকানা যোগ করুন" : "Add New Address")
              : (lang.isBangla ? "ঠিকানা এডিট করুন" : "Edit Address"),
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Personal Information Section
              Obx(() => Text(
                lang.isBangla ? "ব্যক্তিগত তথ্য" : "Personal Information",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
              )),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildTextField(
                      fullNameController,
                      lang.isBangla ? "পূর্ণ নাম" : "Full Name",
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      phoneController,
                      lang.isBangla ? "ফোন নম্বর" : "Phone Number",
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      villageController,
                      lang.isBangla ? "গ্রাম / এলাকা" : "Village / Area",
                      Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      landmarkController,
                      lang.isBangla ? "ল্যান্ডমার্ক" : "Landmark",
                      Icons.landscape_outlined,
                      hint: lang.isBangla ? "মসজিদ, স্কুল, বাজার ইত্যাদি" : "Mosque, School, Market etc.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Select Location on Map
              Obx(() => Text(
                lang.isBangla ? "ম্যাপে লোকেশন চিহ্নিত করুন" : "Select Location on Map",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
              )),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 240,
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
                                        width: 50,
                                        height: 50,
                                        child: Icon(Icons.location_pin, size: 45, color: darkGreen),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Map Control Floating Buttons
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Column(
                                children: [
                                  _buildMapBtn(Icons.my_location, _moveToCurrentLocation),
                                  const SizedBox(height: 6),
                                  _buildMapBtn(Icons.add, _zoomIn),
                                  const SizedBox(height: 6),
                                  _buildMapBtn(Icons.remove, _zoomOut),
                                ],
                              ),
                            ),

                            if (isLoading)
                              Container(
                                color: Colors.black12,
                                child: Center(child: CircularProgressIndicator(color: darkGreen)),
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (selectedLocation != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: darkGreen.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: darkGreen.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: darkGreen, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lang.isBangla
                                    ? "লোকেশন সিলেক্ট করা হয়েছে (${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)})"
                                    : "Location Selected (${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)})",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkGreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Direction Note & Default Switch
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    _buildTextField(
                      noteController,
                      lang.isBangla ? "ডাইরেকশন নোট (ঐচ্ছিক)" : "Direction Note (Optional)",
                      Icons.note_alt_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.grey),
                      child: CheckboxListTile(
                        value: isDefault,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: darkGreen,
                        onChanged: (value) => setState(() => isDefault = value ?? false),
                        title: Text(
                          lang.isBangla ? "ডিফল্ট ঠিকানা হিসেবে সেট করুন" : "Set as Default Address",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Fixed Bottom Save/Update Button to Prevent Overflow
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
          child: Obx(() {
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (fullNameController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty ||
                            villageController.text.trim().isEmpty ||
                            landmarkController.text.trim().isEmpty) {
                          Get.snackbar(
                            lang.isBangla ? "ভুল তথ্য" : "Error",
                            lang.isBangla ? "সবগুলো প্রয়োজনীয় ফিল্ড পূরণ করুন" : "Please fill all required fields",
                            backgroundColor: Colors.orange.shade800,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (selectedLocation == null) {
                          Get.snackbar(
                            lang.isBangla ? "লোকেশন প্রয়োজন" : "Location Required",
                            lang.isBangla ? "দয়া করে ম্যাপ থেকে আপনার স্থান চিহ্নিত করুন" : "Please select location on map",
                            backgroundColor: Colors.orange.shade800,
                            colorText: Colors.white,
                          );
                          return;
                        }

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
                  backgroundColor: darkGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.address == null
                            ? (lang.isBangla ? "ঠিকানা সেভ করুন" : "Save Address")
                            : (lang.isBangla ? "ঠিকানা আপডেট করুন" : "Update Address"),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // Small Helper Widget for Map Action Buttons
  Widget _buildMapBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: textDark),
        onPressed: onTap,
      ),
    );
  }

  // Styled Custom Text Field
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
      style: TextStyle(fontSize: 13, color: textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: darkGreen, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: darkGreen, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
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