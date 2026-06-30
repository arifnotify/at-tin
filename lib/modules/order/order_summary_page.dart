import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tin/modules/address/address_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'order_controller.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  final cart = Get.find<CartController>();
  final address = Get.find<AddressController>();
  final location = Get.find<LocationController>();
  final order = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    order.loadRewardWallet();
  }

  double getSubtotal() => cart.totalPrice.toDouble();

  double getDelivery() {
    return Get.isRegistered<LocationController>()
        ? location.deliveryCharge.value.toDouble()
        : 0;
  }

  double getMaxDiscount() {
    return getSubtotal() + getDelivery();
  }

  double getReward() {
    if (!order.useReward.value) return 0;

    double reward = order.rewardAmount.value.toDouble();
    double maxAllowed = math.min(
      order.walletBalance.value.toDouble(),
      getMaxDiscount(),
    );

    if (reward > maxAllowed) {
      reward = maxAllowed;
      order.rewardAmount.value = reward;
    }

    return reward;
  }

  double getTotal() {
    return (getSubtotal() + getDelivery() - getReward()).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ================= ADDRESS =================
          Obx(() {
            final selected = address.selectedAddress.value;

            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: _card(),

              child: selected == null
                  ? const Text("No address selected")
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Delivery Address",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(selected.fullName),
                        Text(selected.phoneNumber),
                        Text(selected.areaOrVillage),
                        Text("📍 ${selected.landmark}"),
                      ],
                    ),
            );
          }),

          // ================= CART ITEMS =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                final item = cart.cartItems[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: _card(),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.localizedTitle,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Qty: ${item.quantity}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "৳${(item.price * item.quantity).toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ================= REWARD =================
          Obx(() {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(14),
              decoration: _card(borderColor: Colors.orange),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        "Wallet: ৳${order.walletBalance.value.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Use Reward"),
                    value: order.useReward.value,
                    onChanged: (v) {
                      order.useReward.value = v;

                      if (!v) {
                        order.rewardAmount.value = 0;
                      } else {
                        order.rewardAmount.value = math.min(
                          order.walletBalance.value.toDouble(),
                          getMaxDiscount(),
                        );
                      }
                    },
                  ),

                  if (order.useReward.value)
                    Slider(
                      value: order.rewardAmount.value.toDouble(),
                      min: 0,
                      max: math.min(
                        order.walletBalance.value.toDouble(),
                        getMaxDiscount(),
                      ),
                      divisions: 20,
                      label: "৳${order.rewardAmount.value.toStringAsFixed(0)}",
                      onChanged: (v) {
                        order.rewardAmount.value = v;
                      },
                    ),
                ],
              ),
            );
          }),

          // ================= TOTAL =================
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: _card(),

            child: Column(
              children: [
                _row("Subtotal", getSubtotal()),
                _row("Delivery", getDelivery()),
                if (order.useReward.value)
                  _row("Reward", -getReward()),

                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "৳${getTotal().toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= BUTTON =================
          Obx(() {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: order.isLoading.value
                      ? null
                      : () {
                          final selected = address.selectedAddress.value;

                          if (selected == null) {
                            Get.snackbar("Error", "Select address first");
                            return;
                          }

                          order.placeOrder(selected.id);
                        },
                  child: order.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Place Order"),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  BoxDecoration _card({Color? borderColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor ?? Colors.transparent),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        ),
      ],
    );
  }

  Widget _row(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text("৳${value.toStringAsFixed(0)}"),
        ],
      ),
    );
  }
}