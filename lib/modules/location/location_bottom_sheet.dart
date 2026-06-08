import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'location_controller.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Select Location",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.locations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                itemCount: controller.locations.length,
                itemBuilder: (context, index) {
                  final location = controller.locations[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),

                      title: Text(location.district),
                      subtitle: Text(location.division),

                      trailing: Text(
                        "৳${location.deliveryCharge}",
                      ),

                      onTap: () async {
                        await controller.selectLocation(location);
                        Get.back();
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