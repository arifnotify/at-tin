import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'location_controller.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();
    final cartController = Get.find<CartController>(); // 👈 কার্ট চেক করার জন্য যুক্ত করা হয়েছে

    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // =====================
          // TITLE
          // =====================
          const Text(
            "Select Location",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // =====================
          // LOCATION LIST
          // =====================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.locations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.locations.isEmpty) {
                return const Center(
                  child: Text(
                    "No location found",
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.locations.length,
                itemBuilder: (context, index) {
                  final location = controller.locations[index];
                  final isSelected = controller.currentLocationId == location.id;

                  return Card(
                    elevation: isSelected ? 3 : 0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.location_on,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                      title: Text(
                        location.district,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        location.division,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "৳${location.deliveryCharge}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isSelected)
                            const Text(
                              "Selected",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      onTap: () async {
                        // একই লোকেশন হলে ডায়ালগ বা কোনো অ্যাকশনের প্রয়োজন নেই
                        if (isSelected) {
                          Get.back();
                          return;
                        }

                        // কার্টে প্রোডাক্ট থাকলে ডায়ালগ পপ-আপ হবে
                        if (cartController.cartItems.isNotEmpty) {
                          Get.back(); // বটম শিট বন্ধ করুন

Get.dialog(
  Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4), // একদম হালকা কার্ভ, ছবির মতো প্রফেশনাল লুকের জন্য
    ),
    backgroundColor: Colors.white,
    child: Container(
      // স্ক্রিনের উইডথ অনুযায়ী ডায়ালগের সর্বোচ্চ সাইজ কন্ট্রোল করার জন্য
      constraints: const BoxConstraints(maxWidth: 320), 
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16), // স্ট্যান্ডার্ড মিনিমাল প্যাডিং
      child: Column(
        mainAxisSize: MainAxisSize.min, // ভেতরের কন্টেন্ট যতটুকু, ঠিক ততটুকুই হাইট নেবে
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ডায়ালগ টাইটেল
          const Text(
            "Clear Cart?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          
          // ডায়ালগ বডি মেসেজ
          const Text(
            "Changing location will clear your current cart items. Do you want to proceed?",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54, // হালকা অ্যাশ কালার টেক্সট
              height: 1.3, // লাইনের মাঝে সুন্দর গ্যাপের জন্য
            ),
          ),
          const SizedBox(height: 24),
          
          // বাটনস (NO এবং YES অপশন)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ক্যান্সেল বাটন
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  "NO",
                  style: TextStyle(
                    color: Colors.deepPurple, // অথবা আপনার থিম কালার
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // কনফার্ম বাটন
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  Get.back(); // ডায়ালগ বন্ধ করুন
                  await cartController.clearCart();
                  await controller.selectLocation(location);
                  if (Get.isRegistered<HomeController>()) {
                    await Get.find<HomeController>().loadHomeData();
                  }
                },
                child: const Text(
                  "YES",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  ),
  barrierDismissible: false,
);
                        } else {
                          // কার্ট খালি থাকলে কোনো ওয়ার্নিং ছাড়াই সরাসরি চেঞ্জ হবে
                          await controller.selectLocation(location);
                          Get.back();
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}