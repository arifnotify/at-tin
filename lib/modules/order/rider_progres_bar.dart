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

          final carPosition = width * progress;

          return SizedBox(
            height: 55,
            child: Stack(
              children: [

                /// ================= BACKGROUND LINE =================
                Positioned(
                  top: 25,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 9,
                    color: const Color.fromARGB(255, 189, 184, 184),
                  ),
                ),

                /// ================= GREEN PROGRESS LINE =================
                Positioned(
                  top: 25,
                  left: 0,
                  child: Container(
                    height: 5,
                    width: carPosition,
                    color: Colors.green,
                  ),
                ),

                /// ================= START =================
                const Positioned(
                  left: 0,
                  top: 8,
                  child: Text("🏪", style: TextStyle(fontSize: 18)),
                ),

                /// ================= END =================
                const Positioned(
                  right: 0,
                  top: 8,
                  child: Text("🏠", style: TextStyle(fontSize: 18)),
                ),

                /// ================= CAR =================
                Positioned(
                  left: carPosition - 12,
                  top: 10,
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.green,
                    size: 29,
                  ),
                ),

                /// ================= TIME (below car) =================
                Positioned(
                  left: carPosition - 20,
                  top: 35,
                  child: Obx(() => Text(
                        tracking.etaText.value,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(136, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}