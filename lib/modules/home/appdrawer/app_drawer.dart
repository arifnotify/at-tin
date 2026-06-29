import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/order/order_controller.dart';

import 'drawer_controller.dart';
import 'package:tin/modules/support/support_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AuthController auth = Get.find<AuthController>();
  final DrawerControllerX controller = Get.find<DrawerControllerX>();
  final LanguageController languageController = Get.find<LanguageController>();

  final SupportController supportController = Get.put(SupportController());

  /// ================= OPEN URL =================
  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _callPhone(String phone) async {
    if (phone.isEmpty) return;

    await launchUrl(Uri.parse("tel:$phone"));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// PROFILE
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Obx(() {
                        final user = auth.user;

                        return Text(
                          auth.isLoggedIn.value
                              ? (user["phone"] ?? "User")
                              : "Guest User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// LANGUAGE
                  Row(
                    children: [
                      _langButton("EN"),
                      const SizedBox(width: 10),
                      _langButton("BN"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// LOGIN / LOGOUT
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (auth.isLoggedIn.value) {
                            auth.logout();
                            Get.back();
                          } else {
                            Get.back();
                            Get.toNamed("/login");
                          }
                        },
                        icon: Icon(
                          auth.isLoggedIn.value
                              ? Icons.logout
                              : Icons.login,
                        ),
                        label: Text(
                          auth.isLoggedIn.value
                              ? "Logout"
                              : "Login",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            /// ================= MENU =================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

                  /// ================= ORDERS =================
                  Obx(() {
                    if (!auth.isLoggedIn.value) {
                      return const SizedBox();
                    }

                    final orderController = Get.find<OrderController>();
                    final orders = orderController.activeOrders;

                    if (orders.isEmpty) {
                      return const SizedBox();
                    }

                    return ExpansionTile(
                      leading: const Icon(
                        Icons.receipt_long,
                        color: Colors.deepPurple,
                      ),
                      title: const Text(
                        "My Orders",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: orders.map<Widget>((order) {
                        final items = order["items"] ?? [];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ExpansionTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.shopping_bag,
                                  color: Colors.white),
                            ),
                            title: Text(
                              "Order #${order["orderNumber"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Total: ৳${order["totalAmount"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            children: items.map<Widget>((item) {
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item["productImage"] ?? "",
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image),
                                  ),
                                ),
                                title: Text(item["productName"] ?? ""),
                                subtitle: Text("Qty: ${item["quantity"]}"),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    );
                  }),

                  /// ================= TRACKING =================
                  Obx(() {
                    if (!auth.isLoggedIn.value) {
                      return const SizedBox();
                    }

                    final orderController = Get.find<OrderController>();
                    final orders = orderController.activeOrders;

                    final activeOrders = orders.where((order) {
                      final status =
                          order["orderStatus"]?.toString() ?? "";
                      return status != "Delivered" &&
                          status != "Cancelled";
                    }).toList();

                    if (activeOrders.isEmpty) {
                      return const SizedBox();
                    }

                    return ExpansionTile(
                      leading: const Icon(
                        Icons.local_shipping,
                        color: Colors.deepPurple,
                      ),
                      title: const Text("Order Tracking"),
                      children: activeOrders.map((order) {
                        final isSelected =
                            orderController.selectedOrderId.value ==
                                order["_id"];

                        return ListTile(
                          leading: Icon(
                            Icons.receipt_long,
                            color: isSelected ? Colors.green : null,
                          ),
                          title: Text("Order #${order["orderNumber"]}"),
                          subtitle: Text(order["orderStatus"]),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () async {
                            await orderController.selectOrder(order["_id"]);
                            Get.back();
                          },
                        );
                      }).toList(),
                    );
                  }),

                  const Divider(),

                  /// ================= SUPPORT (BACKEND) =================
                  Obx(() {
                    final support = supportController.support.value;

                    if (support == null) {
                      return const SizedBox();
                    }

                    return ExpansionTile(
                      leading: const Icon(
                        Icons.support_agent,
                        color: Colors.deepPurple,
                      ),
                      title: const Text(
                        "Need Help?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.call, color: Colors.green),
                          title: const Text("Call"),
                          onTap: () => _callPhone(support.phone),
                        ),
                        ListTile(
                          leading: const Icon(Icons.message,
                              color: Colors.green),
                          title: const Text("WhatsApp"),
                          onTap: () => _openUrl(support.whatsapp),
                        ),
                        ListTile(
                          leading: const Icon(Icons.facebook,
                              color: Colors.blue),
                          title: const Text("Facebook"),
                          onTap: () => _openUrl(support.facebook),
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt,
                              color: Colors.purple),
                          title: const Text("Instagram"),
                          onTap: () => _openUrl(support.instagram),
                        ),
                        ListTile(
                          leading: const Icon(Icons.forum,
                              color: Colors.deepPurple),
                          title: const Text("Messenger"),
                          onTap: () => _openUrl(support.messenger),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= LANGUAGE BUTTON =================
  Widget _langButton(String text) {
    return Obx(() {
      final isSelected =
          languageController.currentLanguage.value ==
              (text == "BN" ? "bn" : "en");

      return GestureDetector(
        onTap: () {
          languageController.changeLanguage(
            text == "BN" ? "bn" : "en",
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? Colors.deepPurple
                  : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}