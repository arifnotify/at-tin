import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/reward/reward_controller.dart';
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
  final RewardController rewardController = Get.find<RewardController>();

  // See More ট্র্যাকিং করার জন্য Reactive Observable ভেরিয়েবল
  final RxBool _showAllTransactions = false.obs;

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
    const Color primaryGolden = Color(0xFF8B6E30); 
    const Color bgGoldenLight = Color(0xFFFAF7F0);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: bgGoldenLight,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Obx(() {
                final user = auth.user;
                final isLoggedIn = auth.isLoggedIn.value;
                final customerType = user["customerType"] ?? "REGULAR";
                final phone = user["phone"] ?? "01XXXXXXXXX";
                final isBn = languageController.isBangla;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// PROFILE AVATAR
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryGolden, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 28,
                          color: primaryGolden,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// PHONE NUMBER & BADGE IN COLUMN
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLoggedIn ? phone : (isBn ? "অতিথি ব্যবহারকারী" : "Guest User"),
                            style: const TextStyle(
                              color: Color(0xFF4A3B18),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLoggedIn) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryGolden.withOpacity(0.4)),
                              ),
                              child: Text(
                                customerType.toUpperCase(),
                                style: const TextStyle(
                                  color: primaryGolden,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    /// LANGUAGE TOGGLE
                    _buildLanguageToggle(),
                  ],
                );
              }),
            ),

            const SizedBox(height: 10),

            /// ================= MENU ITEMS WITH DROPDOWN DOWN =================
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    
                    /// ================= MY ORDERS =================
                    Obx(() {
                      if (!auth.isLoggedIn.value) return const SizedBox();

                      final orderController = Get.find<OrderController>();
                      final orders = orderController.activeOrders;
                      final isBn = languageController.isBangla;

                      if (orders.isEmpty) return const SizedBox();

                      return _buildExpansionSection(
                        icon: Icons.receipt_long,
                        title: isBn ? "আমার অর্ডারসমূহ" : "My Orders",
                        children: orders.map<Widget>((order) {
                          final items = order["items"] ?? [];

                          final rawAmount = order["finalAmount"] ?? 0;
                          final formattedAmount = double.parse(rawAmount.toString()).toStringAsFixed(2);

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ExpansionTile(
                              leading: const CircleAvatar(
                                backgroundColor: primaryGolden,
                                radius: 16,
                                child: Icon(Icons.shopping_bag, color: Colors.white, size: 16),
                              ),
                              title: Text(
                                isBn ? "অর্ডার #${order["orderNumber"]}" : "Order #${order["orderNumber"]}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                isBn ? "মোট: ৳$formattedAmount" : "Total: ৳$formattedAmount",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGolden, fontSize: 12),
                              ),
                              children: items.map<Widget>((item) {
                                // productName অবজেক্ট বা স্টریং হ্যান্ডেল করা
                                final rawProductName = item["productName"];
                                final String productNameText = (rawProductName is Map)
                                    ? (isBn ? (rawProductName["bn"] ?? rawProductName["en"] ?? "") : (rawProductName["en"] ?? ""))
                                    : (rawProductName?.toString() ?? "");

                                // ইউনিট হ্যান্ডেল করা
                                final rawUnit = item["unit"];
                                final String unitText = (rawUnit is Map)
                                    ? (isBn ? (rawUnit["bn"] ?? rawUnit["en"] ?? "") : (rawUnit["en"] ?? ""))
                                    : (rawUnit?.toString() ?? "");

                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item["productImage"] ?? "",
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40),
                                    ),
                                  ),
                                  title: Text(productNameText, style: const TextStyle(fontSize: 13)),
                                  subtitle: Text(
                                    isBn 
                                      ? "পরিমাণ: ${item["quantity"]} $unitText" 
                                      : "Qty: ${item["quantity"]} $unitText", 
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      );
                    }),

                    /// ================= TRANSACTIONS (MAX 3 ITEMS + SEE MORE) =================
                    Obx(() {
                      if (!auth.isLoggedIn.value) return const SizedBox();

                      if (rewardController.txLoading.value) {
                        return const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: primaryGolden)));
                      }

                      final List<dynamic> allTx = rewardController.transactions;
                      if (allTx.isEmpty) return const SizedBox();
                      final isBn = languageController.isBangla;

                      final displayedTx = _showAllTransactions.value 
                          ? allTx 
                          : allTx.take(3).toList();

                      List<Widget> txWidgets = displayedTx.map<Widget>((txItem) {
                        final Map<String, dynamic> tx = Map<String, dynamic>.from(txItem as Map);
                        
                        final type = tx["type"]?.toString() ?? "";
                        final isEarn = type == "EARN";

                        final rawAmount = tx["amount"] ?? 0;
                        final formattedAmount = double.parse(rawAmount.toString()).toStringAsFixed(2);

                        return ListTile(
                          leading: Icon(
                            isEarn ? Icons.add_circle : Icons.remove_circle,
                            color: isEarn ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          title: Text("৳$formattedAmount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(tx["description"]?.toString() ?? "", style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                            type == "EARN" ? (isBn ? "অর্জিত" : "EARN") : (isBn ? "ব্যয়িত" : "SPENT"),
                            style: TextStyle(color: isEarn ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        );
                      }).toList();

                      if (allTx.length > 3) {
                        txWidgets.add(
                          InkWell(
                            onTap: () {
                              _showAllTransactions.value = !_showAllTransactions.value;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showAllTransactions.value 
                                        ? (isBn ? "কম দেখুন" : "See Less") 
                                        : (isBn ? "আরও দেখুন" : "See More"),
                                    style: const TextStyle(
                                      color: primaryGolden,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Icon(
                                    _showAllTransactions.value 
                                        ? Icons.keyboard_arrow_up 
                                        : Icons.keyboard_arrow_down,
                                    color: primaryGolden,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return _buildExpansionSection(
                        icon: Icons.history,
                        title: isBn ? "লেনদেন সমূহ" : "Transactions",
                        children: txWidgets,
                      );
                    }),

                    /// ================= ORDER TRACKING =================
                    Obx(() {
                      if (!auth.isLoggedIn.value) return const SizedBox();

                      final orderController = Get.find<OrderController>();
                      final orders = orderController.activeOrders;
                      final isBn = languageController.isBangla;

                      final activeOrders = orders.where((order) {
                        final status = order["orderStatus"]?.toString() ?? "";
                        return status != "Delivered" && status != "Cancelled";
                      }).toList();

                      if (activeOrders.isEmpty) return const SizedBox();

                      return _buildExpansionSection(
                        icon: Icons.local_shipping,
                        title: isBn ? "অর্ডার ট্র্যাকিং" : "Order Tracking",
                        children: activeOrders.map((order) {
                          final isSelected = orderController.selectedOrderId.value == order["_id"];

                          return ListTile(
                            leading: Icon(
                              Icons.receipt_long,
                              color: isSelected ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            title: Text(isBn ? "অর্ডার #${order["orderNumber"]}" : "Order #${order["orderNumber"]}", style: const TextStyle(fontSize: 14)),
                            subtitle: Text(order["orderStatus"]?.toString() ?? "", style: const TextStyle(fontSize: 12)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green, size: 20) : null,
                            onTap: () async {
                              await orderController.selectOrder(order["_id"]);
                              Get.back();
                            },
                          );
                        }).toList(),
                      );
                    }),

                    /// ================= NEED HELP / SUPPORT =================
                    Obx(() {
                      final support = supportController.support.value;
                      if (support == null) return const SizedBox();
                      final isBn = languageController.isBangla;

                      return _buildExpansionSection(
                        icon: Icons.support_agent,
                        title: isBn ? "সাহায্য প্রয়োজন?" : "Need Help?",
                        children: [
                          _buildSupportItem(Icons.call, isBn ? "কল করুন" : "Call", Colors.green, () => _callPhone(support.phone)),
                          _buildSupportItem(Icons.message, "WhatsApp", Colors.green, () => _openUrl(support.whatsapp)),
                          _buildSupportItem(Icons.facebook, "Facebook", Colors.blue, () => _openUrl(support.facebook)),
                          _buildSupportItem(Icons.camera_alt, "Instagram", Colors.purple, () => _openUrl(support.instagram)),
                          _buildSupportItem(Icons.forum, "Messenger", primaryGolden, () => _openUrl(support.messenger)),
                        ],
                      );
                    }),

                  ],
                ),
              ),
            ),

            /// ================= LOGOUT BUTTON =================
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                final isLoggedIn = auth.isLoggedIn.value;
                final isBn = languageController.isBangla;
                
                String buttonText = "";
                if (isLoggedIn) {
                  buttonText = isBn ? "লগআউট" : "Logout";
                } else {
                  buttonText = isBn ? "লগইন" : "Login";
                }

                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (isLoggedIn) {
                        auth.logout();
                      } else {
                        Get.toNamed("/login");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGolden,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Icon(isLoggedIn ? Icons.logout : Icons.login, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CUSTOM RE-DESIGNED EXPANSION TILE =================
  Widget _buildExpansionSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    const Color primaryGolden = Color(0xFF8B6E30);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: ExpansionTile(
        trailing: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFFC4B595)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryGolden.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryGolden, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: children,
      ),
    );
  }

  /// Helper widget for support items
  Widget _buildSupportItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      onTap: onTap,
    );
  }

  /// ================= LANGUAGE TOGGLE DESIGN =================
  Widget _buildLanguageToggle() {
    const Color primaryGolden = Color(0xFF8B6E30);

    return Obx(() {
      final currentLang = languageController.currentLanguage.value;

      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryGolden.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangButton("EN", currentLang == "en"),
            _buildLangButton("BN", currentLang == "bn"),
          ],
        ),
      );
    });
  }

  Widget _buildLangButton(String text, bool isSelected) {
    const Color primaryGolden = Color(0xFF8B6E30);

    return GestureDetector(
      onTap: () {
        languageController.changeLanguage(text == "BN" ? "bn" : "en");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryGolden : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryGolden,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}