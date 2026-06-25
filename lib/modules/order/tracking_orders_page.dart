import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/services/order_service.dart';

class TrackingOrdersPage extends StatefulWidget {
  const TrackingOrdersPage({super.key});

  @override
  State<TrackingOrdersPage> createState() =>
      _TrackingOrdersPageState();
}

class _TrackingOrdersPageState extends State<TrackingOrdersPage> {
  final service = OrderService();

  List orders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await service.getMyOrders();

    setState(() {
      orders = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final o = orders[i];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),

                    title: Text("Order #${o["orderNumber"]}"),

                    subtitle: Text(o["orderStatus"] ?? ""),

                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () {
                      Get.toNamed("/tracking/${o["_id"]}");
                    },
                  ),
                );
              },
            ),
    );
  }
}