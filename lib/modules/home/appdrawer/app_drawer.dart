import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/auth/auth_controller.dart';

import 'drawer_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final AuthController auth = Get.find<AuthController>();
  final DrawerControllerX controller =
      Get.find<DrawerControllerX>();

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

                  /// PROFILE SECTION
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
                        return Text(
                          auth.isLoggedIn.value
                              ? "My Profile"
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

                  /// LANGUAGE SWITCH (NO nested Obx inside widget)
                  Row(
                    children: [
                      _langButton("EN"),
                      const SizedBox(width: 10),
                      _langButton("BN"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// LOGIN / LOGOUT BUTTON
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

                  _item(Icons.home, "Home", () => Get.back()),

                  _item(Icons.grid_view, "Categories",
                      () => Get.toNamed("/categories")),

                  _item(Icons.shopping_cart, "Cart",
                      () => Get.toNamed("/cart")),

                  _item(Icons.receipt_long, "Orders",
                      () => Get.toNamed("/orders")),

                  const Divider(),

                  _item(Icons.support_agent, "Support", () {}),

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
          controller.selectedLang.value == text;

      return GestureDetector(
        onTap: () {
          controller.selectedLang.value = text;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent,
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

  /// ================= MENU ITEM =================
  Widget _item(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: onTap,
    );
  }
}