import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tin/data/services/order_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingPage> createState() =>
      _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final service = OrderService();

  Timer? timer;

  double lat = 0;
  double lng = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetch();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetch(),
    );
  }

  Future<void> fetch() async {
    final res = await service.getTracking(widget.orderId);

    final rider = res["rider"];

    setState(() {
      loading = false;

      if (rider != null) {
        lat = (rider["lat"] ?? 0).toDouble();
        lng = (rider["lng"] ?? 0).toDouble();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (lat == 0 && lng == 0) {
      return const Scaffold(
        body: Center(child: Text("Rider not available")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Track Rider")),

      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),

          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lng),
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}