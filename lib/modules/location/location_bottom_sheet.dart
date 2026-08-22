import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/home_controller.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'location_controller.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();
    final cartController = Get.find<CartController>();
    final languageController = Get.find<LanguageController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.50,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // =====================
          // DRAG HANDLE & HEADER
          // =====================
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      languageController.isBangla
                          ? "ডেলিভারি লোকেশন সিলেক্ট করুন"
                          : "Select Delivery Location",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    )),
                InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // =====================
          // LOCATION LIST
          // =====================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.locations.isEmpty) {
                // এখানে CircularProgressIndicator এর জায়গায় AppLoader বসানো হয়েছে
                return const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: AppLoader(),
                  ),
                );
              }

              if (controller.locations.isEmpty) {
                return Center(
                  child: Text(
                    languageController.isBangla ? "কোনো লোকেশন পাওয়া যায়নি" : "No locations available",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.locations.length,
                itemBuilder: (context, index) {
                  final location = controller.locations[index];
                  final isSelected = controller.currentLocationId == location.id;
                  final isBangla = languageController.isBangla;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.shade50.withOpacity(0.6) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        isBangla ? location.district.bn : location.district.en,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.deepPurple : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        isBangla ? location.division.bn : location.division.en,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "৳${location.deliveryCharge}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                isBangla ? "ডেলিভারি" : "Delivery",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.deepPurple,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      onTap: () async {
                        if (isSelected) {
                          Get.back();
                          return;
                        }

                        if (cartController.cartItems.isNotEmpty) {
                          Get.back();
                          _showClearCartDialog(context, location, controller, cartController, isBangla);
                        } else {
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

  // =====================
  // CLEAR CART DIALOG
  // =====================
  void _showClearCartDialog(
    BuildContext context,
    dynamic location,
    LocationController controller,
    CartController cartController,
    bool isBangla,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.remove_shopping_cart_rounded, color: Colors.amber.shade800, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBangla ? "কার্ট খালি করবেন?" : "Clear Cart?",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isBangla
                    ? "লোকেশন পরিবর্তন করলে আপনার বর্তমান কার্টের প্রোডাক্টগুলো মুছে যাবে। আপনি কি এগিয়ে যেতে চান?"
                    : "Changing location will clear your current cart items. Do you want to proceed?",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: Text(isBangla ? "না" : "NO", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () async {
                      Get.back();
                      await cartController.clearCart();
                      await controller.selectLocation(location);
                      if (Get.isRegistered<HomeController>()) {
                        await Get.find<HomeController>().loadHomeData();
                      }
                    },
                    child: Text(
                      isBangla ? "হ্যাঁ" : "YES",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
  }
}