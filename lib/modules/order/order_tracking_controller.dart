import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:tin/data/services/order_service.dart';
import 'package:tin/modules/order/order_controller.dart';

class OrderTrackingController extends GetxController {
  final OrderService service = OrderService();

  /// Rider Location
  RxDouble riderLat = 0.0.obs;
  RxDouble riderLng = 0.0.obs;

  /// Destination Location
  RxDouble destLat = 0.0.obs;
  RxDouble destLng = 0.0.obs;

  /// Progress
  RxDouble progress = 0.0.obs;

  /// Status
  RxString status = "".obs;

  /// Tracking Enabled
  RxBool trackingEnabled = false.obs;

  /// Loading
  RxBool isLoading = false.obs;

  /// ETA
  RxString etaText = "-- min".obs;

  /// Current Tracking Order
  RxString currentOrderId = "".obs;

  Timer? timer;

  // ==========================
  // START TRACKING
  // ==========================


  void startTracking(String orderId) {
    if (currentOrderId.value == orderId &&
        timer != null) {
      return;
    }

    stopTracking();

    currentOrderId.value = orderId;

    fetch(orderId);

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetch(orderId),
    );
  }

  // ==========================
  // STOP TRACKING
  // ==========================

  void stopTracking() {
    timer?.cancel();

    currentOrderId.value = "";

    trackingEnabled.value = false;

    riderLat.value = 0;
    riderLng.value = 0;

    destLat.value = 0;
    destLng.value = 0;

    progress.value = 0;

    etaText.value = "-- min";

    status.value = "";
  }

  // ==========================
  // FETCH TRACKING
  // ==========================

  Future<void> fetch(String orderId) async {
    try {
      final data =
          await service.getTracking(orderId);

      status.value =
          data["status"]?.toString() ?? "";

      trackingEnabled.value =
          data["trackingEnabled"] ?? false;

      /// Delivered / Cancelled
      if (status.value == "Delivered" ||
          status.value == "Cancelled") {
        final order =
            Get.find<OrderController>();

        order.removeOrder(
          orderId,
        );

        stopTracking();

        return;
      }

      final rider = data["rider"];
      final destination =
          data["destination"];

      if (rider != null &&
          destination != null) {
        riderLat.value =
            (rider["lat"] ?? 0)
                .toDouble();

        riderLng.value =
            (rider["lng"] ?? 0)
                .toDouble();

        destLat.value =
            (destination["lat"] ?? 0)
                .toDouble();

        destLng.value =
            (destination["lng"] ?? 0)
                .toDouble();

        _calculateProgress();
        _calculateEta();
      }

      isLoading.value = false;
    } catch (e) {
      print(
        "Tracking Error => $e",
      );
    }
  }

  // ==========================
  // PROGRESS
  // ==========================

  void _calculateProgress() {
    final distance =
        Geolocator.distanceBetween(
      riderLat.value,
      riderLng.value,
      destLat.value,
      destLng.value,
    );

    const maxDistance = 5000;

    double p =
        1 - (distance / maxDistance);

    progress.value =
        p.clamp(0.0, 1.0);
  }

  // ==========================
  // ETA
  // ==========================

  void _calculateEta() {
    final distanceMeters =
        Geolocator.distanceBetween(
      riderLat.value,
      riderLng.value,
      destLat.value,
      destLng.value,
    );

    /// 25km/h rider speed
    const speedMetersPerMinute =
        416.67;

    final minutes =
        (distanceMeters /
                speedMetersPerMinute)
            .ceil();

    etaText.value =
        "$minutes min";
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}