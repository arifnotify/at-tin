import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_tracking_controller.dart';

class RiderProgressLine extends StatelessWidget {
  const RiderProgressLine({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = Get.find<OrderTrackingController>();

    return Obx(() {
      if (!tracking.trackingEnabled.value) {
        return const SizedBox();
      }

      return LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final progress = tracking.progress.value.clamp(0.0, 1.0);

          // আইকন যাতে স্ক্রিনের বাইরে না চলে যায়
          final carPosition = (width * progress).clamp(16.0, width - 16.0);

          return SizedBox(
            height: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// ================= BACKGROUND GREY LINE =================
                Positioned(
                  top: 22,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// ================= GREEN PROGRESS LINE (WITH WHITE BORDER/SIDE) =================
                Positioned(
                  top: 20, // কিছুটা উপরে তুলে প্যাডিংয়ের জন্য জায়গা দেওয়া হয়েছে
                  left: 0,
                  child: Container(
                    height: 12, // সাদা ব্যাকগ্রাউন্ড সমেত উচ্চতা
                    width: (width * progress).clamp(0.0, width),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4.5,
                    ), // চারপাশে সাদা মার্জিন রাখার জন্য প্যাডিং
                    decoration: BoxDecoration(
                      color: Colors.white, // পুরো সাইডে সাদা ব্যাকগ্রাউন্ড
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Container(
                      height: 3, // একদম চিকন ৩px গ্রিন লাইন
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                /// ================= START ICON (SHOP) =================
                const Positioned(
                  left: 0,
                  top: 10,
                  child: Text("🏪", style: TextStyle(fontSize: 18)),
                ),

                /// ================= END ICON (HOME) =================
                const Positioned(
                  right: 0,
                  top: 10,
                  child: Text("🏠", style: TextStyle(fontSize: 18)),
                ),

                /// ================= CAR / RIDER ICON =================
                Positioned(
                  left: carPosition - 14,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),

                /// ================= TIME (ETA BELOW CAR) =================
                Positioned(
                  left: (carPosition - 30).clamp(0.0, width - 60.0),
                  top: 38,
                  child: Obx(
                    () => Text(
                      tracking.etaText.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}