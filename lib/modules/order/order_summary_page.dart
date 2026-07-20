import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/address/address_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/address/add_address_page.dart'; 
import 'package:tin/modules/home/widgets/app_loader.dart'; 
import 'order_controller.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  final cart = Get.find<CartController>();
  final address = Get.put(AddressController());
  final location = Get.find<LocationController>();
  final order = Get.find<OrderController>();

  // Scrollbar এরর দূর করার জন্য ScrollController
  final ScrollController _addressScrollController = ScrollController();

  // Payment State Variables
  final RxString selectedPaymentMethod = 'cod'.obs; // 'bkash', 'nagad', 'cod'
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  // Premium Theme Colors
  final Color bgCream = const Color(0xFFF7F4EB);
  final Color cardColor = const Color(0xFFFCFAF2);
  final Color accentGold = const Color(0xFFD4AF37);
  final Color darkGreen = const Color(0xFF1D4D33);
  final Color textDark = const Color(0xFF2C2520);

  @override
  void initState() {
    super.initState();
    order.loadRewardWallet();
  }

  @override
  void dispose() {
    phoneController.dispose();
    pinController.dispose();
    _addressScrollController.dispose();
    super.dispose();
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

  // ফিক্সড: build মেথডের বাইরে সেফলি রিওয়ার্ড ভ্যালু রিটার্ন করার ফাংশন
  double getReward() {
    if (!order.useReward.value) return 0;

    double reward = order.rewardAmount.value.toDouble();
    double maxAllowed = math.min(
      order.walletBalance.value.toDouble(),
      getMaxDiscount(),
    );

    // build-এর ভেতর ডাইরেক্ট order.rewardAmount.value চেঞ্জ না করে শুধু ভ্যালুটি রিটার্ন করা হচ্ছে
    if (reward > maxAllowed) {
      return maxAllowed;
    }
    return reward;
  }

  // ফিক্সড: রিওয়ার্ড পরিবর্তন করার জন্য সেফ স্টেট হ্যান্ডলার ফাংশন
  void updateRewardAmount(double newAmount) {
    double maxAllowed = math.min(
      order.walletBalance.value.toDouble(),
      getMaxDiscount(),
    );
    if (newAmount > maxAllowed) {
      order.rewardAmount.value = maxAllowed;
    } else {
      order.rewardAmount.value = newAmount;
    }
  }

  double getTotal() {
    return (getSubtotal() + getDelivery() - getReward()).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Checkout",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1 & 2: ADDRESS AND ITEMS =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Obx(() {
                    if (address.isLoading.value) {
                      return Container(
                        height: 250,
                        decoration: _cardDecoration(),
                        child: const Center(child: AppLoader()),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sectionHeader("1. Address"),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.add_circle_outline, color: darkGreen, size: 20),
                                onPressed: () {
                                  Get.to(() => const AddAddressPage());
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (address.addresses.isEmpty)
                            Container(
                              height: 120,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Address Found",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => Get.to(() => const AddAddressPage()),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text("Add New Address", style: TextStyle(fontSize: 11)),
                                  )
                                ],
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Scrollbar(
                                controller: _addressScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: ListView.builder(
                                  controller: _addressScrollController,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(right: 8),
                                  itemCount: address.addresses.length,
                                  itemBuilder: (context, index) {
                                    final addr = address.addresses[index];
                                    
                                    return Obx(() {
                                      final isSelected = address.selectedAddress.value?.id == addr.id;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFF3EFE0) : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected ? accentGold : Colors.grey.shade300,
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            unselectedWidgetColor: Colors.grey,
                                          ),
                                          child: RadioListTile<String>(
                                            value: addr.id,
                                            groupValue: address.selectedAddress.value?.id,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                            activeColor: darkGreen,
                                            onChanged: (val) {
                                              if (val != null) {
                                                address.selectAddress(addr);
                                              }
                                            },
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    addr.fullName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: textDark,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                if (addr.isDefault)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade600,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text(
                                                      "Def",
                                                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                _buildAddressMenu(addr),
                                              ],
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  addr.phoneNumber, 
                                                  style: TextStyle(fontSize: 10, color: textDark.withOpacity(0.8))
                                                ),
                                                Text(
                                                  "${addr.areaOrVillage}, ${addr.landmark}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 9, color: textDark.withOpacity(0.6)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),

                // Right Column: Your Items
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader("2. Your Items"),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: cart.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cart.cartItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.image,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(color: Colors.grey, width: 40, height: 40),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.localizedTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textDark),
                                            ),
                                            Text(
                                              "৳${item.price.toStringAsFixed(0)} x ${item.quantity}",
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subtotal:", style: TextStyle(fontSize: 12, color: textDark)),
                            Text(
                              "৳${getSubtotal().toStringAsFixed(0)}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ================= 3: REWARD DETAILS =================
            Obx(() {
              double maxAllowedReward = math.min(
                order.walletBalance.value.toDouble(),
                getMaxDiscount(),
              );

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(
                  borderColor: accentGold.withOpacity(0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionHeader("3. Reward Details"),
                        Row(
                          children: [
                            Icon(Icons.star, color: accentGold, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              "Wallet: ৳${order.walletBalance.value.toStringAsFixed(0)}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE5C07B), Color(0xFFC39B54)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Use Reward", style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 13)),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      activeColor: accentGold,
                                      value: order.useReward.value,
                                      onChanged: (v) {
                                        // ফিক্সড: মেইন থ্রেডে সিকিউরলি ভ্যালু অ্যাসাইন করার জন্য WidgetsBinding দিয়ে র‍্যাপ করা হলো
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          order.useReward.value = v;
                                          if (!v) {
                                            order.rewardAmount.value = 0;
                                          } else {
                                            order.rewardAmount.value = maxAllowedReward;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (order.useReward.value) ...[
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: accentGold,
                                    thumbColor: accentGold,
                                    inactiveTrackColor: Colors.grey.shade300,
                                  ),
                                  child: Slider(
                                    value: order.rewardAmount.value.toDouble().clamp(0, maxAllowedReward),
                                    min: 0,
                                    max: maxAllowedReward > 0 ? maxAllowedReward : 1.0, // Error এড়াতে মিনিমাম লিমিট নিশ্চিত করা হলো
                                    onChanged: (v) {
                                      // ফিক্সড: স্লাইডারে কলব্যাক ব্যবহার করে সিকিউরলি আপডেট করা হচ্ছে
                                      updateRewardAmount(v);
                                    },
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "৳${getReward().toStringAsFixed(0)}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // ================= 4: SELECT PAYMENT METHOD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("4. Select Payment Method"),
                  const SizedBox(height: 16),
                  Obx(() {
                    return Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _paymentMethodButton(
                                label: "bKash",
                                type: "bkash",
                                isSelected: selectedPaymentMethod.value == 'bkash',
                              ),
                              const SizedBox(height: 10),
                              _paymentMethodButton(
                                label: "Nagad",
                                type: "nagad",
                                isSelected: selectedPaymentMethod.value == 'nagad',
                              ),
                              const SizedBox(height: 10),
                              _paymentMethodButton(
                                label: "Cash on\nDelivery",
                                type: "cod",
                                iconData: Icons.local_shipping,
                                isSelected: selectedPaymentMethod.value == 'cod',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: (selectedPaymentMethod.value == 'bkash' || selectedPaymentMethod.value == 'nagad')
                                ? Column(
                                    key: ValueKey(selectedPaymentMethod.value),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Enter Number (${selectedPaymentMethod.value == 'bkash' ? 'bKash' : 'Nagad'})",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textDark),
                                      ),
                                      const SizedBox(height: 4),
                                      _inputField(
                                        controller: phoneController,
                                        hintText: "(e.g., 017XXXXXXXX)",
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Enter Password / PIN",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textDark),
                                      ),
                                      const SizedBox(height: 4),
                                      _inputField(
                                        controller: pinController,
                                        hintText: "Enter confidential PIN",
                                        obscureText: true,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  )
                                : Container(
                                    key: const ValueKey('empty_input'),
                                    height: 140,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "No credentials required for COD",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                  const SizedBox(height: 10),
                  Obx(() {
                    return Column(
                      children: [
                        _summaryRow("Subtotal", getSubtotal()),
                        _summaryRow("Delivery", getDelivery()),
                        _summaryRow("Reward", -getReward(), isDiscount: true),
                        const Divider(thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark),
                            ),
                            Text(
                              "৳${getTotal().toStringAsFixed(0)}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: darkGreen),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ================= PROCEED TO PAYMENT BUTTON =================
            Obx(() {
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                  onPressed: order.isLoading.value
                      ? null
                      : () {
                          final selectedAddr = address.selectedAddress.value;

                          if (selectedAddr == null || address.addresses.isEmpty) {
                            Get.snackbar(
                              "Address Required",
                              "দয়া করে আপনার ডেলিভারি অ্যাড্রেস যোগ করুন এবং সিলেক্ট করুন।",
                              backgroundColor: Colors.orange.shade800,
                              colorText: Colors.white,
                              icon: const Icon(Icons.location_off, color: Colors.white),
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(12),
                              duration: const Duration(seconds: 3),
                            );
                            return;
                          }

                          if ((selectedPaymentMethod.value == 'bkash' || selectedPaymentMethod.value == 'nagad') &&
                              (phoneController.text.isEmpty || pinController.text.isEmpty)) {
                            Get.snackbar(
                              "Required Field",
                              "Please enter valid number & PIN",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          order.placeOrder(selectedAddr.id);
                        },
                  child: order.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Proceed to Payment",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.lock_outline, size: 18, color: accentGold),
                          ],
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ================= STYLING & CUSTOM COMPONENTS =================

  BoxDecoration _cardDecoration({Color? borderColor}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor ?? Colors.grey.shade300, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: textDark,
      ),
    );
  }

  // ফিক্সড: ৪0৪ ইমেজ এরর ও ক্র্যাশ এড়াতে ইমেজের সঠিক নেটওয়ার্ক প্লেসহোল্ডার বা লোকাল লজিক সেট করা হয়েছে
  Widget _paymentMethodButton({
    required String label,
    required String type,
    IconData? iconData,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => selectedPaymentMethod.value = type,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? darkGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // bKash ও Nagad-এর জন্য সিম্পল আইকন ব্যবহার করা হয়েছে ইমেজ এরর এবং ক্র্যাশ এড়ানোর জন্য
            Icon(
              type == 'bkash' || type == 'nagad' ? Icons.account_balance_wallet : (iconData ?? Icons.local_shipping),
              color: isSelected ? darkGreen : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                  color: textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 12, color: textDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkGreen),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(
            "${isDiscount ? '-' : ''}৳${amount.abs().toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red.shade600 : textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressMenu(dynamic addr) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 16, color: textDark.withOpacity(0.6)),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) async {
        if (value == 'edit') {
          Get.to(() => AddAddressPage(address: addr));
        } else if (value == 'delete') {
          _showDeleteConfirmationDialog(addr);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, size: 18),
            title: Text('Edit', style: TextStyle(fontSize: 12)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red, size: 18),
            title: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(dynamic addr) {
    Get.defaultDialog(
      title: "Delete Address",
      titleStyle: TextStyle(fontWeight: FontWeight.bold, color: textDark),
      middleText: "আপনি কি নিশ্চিতভাবে এই অ্যাড্রেসটি ডিলিট করতে চান?",
      middleTextStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
      backgroundColor: cardColor,
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      cancelTextColor: textDark,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        address.deleteAddress(addr.id); 
        Get.back(); 
        Get.snackbar(
          "Deleted Successfully",
          "আপনার অ্যাড্রেসটি মুছে ফেলা হয়েছে।",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      },
    );
  }
}