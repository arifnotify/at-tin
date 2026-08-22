import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/address/add_address_page.dart';
import 'package:tin/modules/address/address_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/payment/payment_settings_controller.dart';
import 'order_controller.dart';
import 'order_confirmation_dialog.dart'; // নতুন ডায়ালগ ফাইল ইমপোর্ট করা হয়েছে

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
  final paymentSettings = Get.find<PaymentSettingsController>();

  final lang = Get.isRegistered<LanguageController>()
      ? Get.find<LanguageController>()
      : Get.put(LanguageController());

  final ScrollController _addressScrollController = ScrollController();
  final RxString selectedPaymentMethod=''.obs;

// ব্যাকগ্রাউন্ড সম্পূর্ণ সাদা করা হয়েছে
  final Color bgCream = Colors.white;
  final Color cardColor = Colors.white;
  final Color accentGold = const Color(0xFFD4AF37);
  final Color darkGreen = const Color(0xFF1D4D33);
  final Color textDark = const Color(0xFF2C2520);

@override
void initState() {
  super.initState();

  order.loadRewardWallet();

  paymentSettings.fetchPaymentSettings();

  Future.delayed(
    const Duration(milliseconds: 300),
    () {

      if (paymentSettings.codEnabled.value) {

        selectedPaymentMethod.value = "COD";

      } else if (paymentSettings.sslcommerzEnabled.value) {

        selectedPaymentMethod.value = "SSLCOMMERZ";

      }

    },
  );
}

  @override
  void dispose() {
    _addressScrollController.dispose();
    super.dispose();
  }

  String _toBnNum(String number) {
    if (!lang.isBangla) return number;
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < englishDigits.length; i++) {
      number = number.replaceAll(englishDigits[i], banglaDigits[i]);
    }
    return number;
  }

  double getSubtotal() => cart.totalPrice.toDouble();

  double getDelivery() {
    return Get.isRegistered<LocationController>()
        ? location.deliveryCharge.value.toDouble()
        : 0;
  }

  double getMaxDiscount() => getSubtotal();

  double getReward() {
    if (!order.useReward.value) return 0;
    double reward = order.rewardAmount.value.toDouble();
    double maxAllowed = math.min(
      order.walletBalance.value.toDouble(),
      getMaxDiscount(),
    );
    return reward > maxAllowed ? maxAllowed : reward;
  }

  void updateRewardAmount(double newAmount) {
    double maxAllowed = math.min(
      order.walletBalance.value.toDouble(),
      getMaxDiscount(),
    );
    order.rewardAmount.value = newAmount > maxAllowed ? maxAllowed : newAmount;
  }

  double getTotal() {
    double subtotalAfterReward = (getSubtotal() - getReward()).clamp(0, double.infinity);
    return subtotalAfterReward + getDelivery();
  }

  void _handlePlaceOrder(String addressId) async {
    await order.placeOrder(
      addressId,
      paymentMethod: selectedPaymentMethod.value,
    );
  }

  // আলাদা ফাইল থেকে পপ-আপ কল করার মেথড
  void _openConfirmationPopup(BuildContext context, dynamic selectedAddr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return OrderConfirmationDialog(
          selectedAddr: selectedAddr,
          paymentMethod: selectedPaymentMethod.value,
          subtotal: getSubtotal(),
          rewardDiscount: getReward(),
          deliveryCharge: getDelivery(),
          total: getTotal(),
          onConfirm: () {
            _handlePlaceOrder(selectedAddr.id);
          },
        );
      },
    );
  }

  Widget _buildAddressMenu(dynamic addr) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) {
        if (value == 'edit') {
          Get.to(() => AddAddressPage(address: addr));
        } else if (value == 'delete') {
          address.deleteAddress(addr.id);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'edit',
          height: 32,
          child: Row(
            children: [
              const Icon(Icons.edit, size: 14, color: Colors.blue),
              const SizedBox(width: 8),
              Text(lang.isBangla ? 'এডিট' : 'Edit', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 32,
          child: Row(
            children: [
              const Icon(Icons.delete, size: 14, color: Colors.red),
              const SizedBox(width: 8),
              Text(lang.isBangla ? 'মুছুন' : 'Delete', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration({Color? borderColor}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor ?? Colors.grey.shade300, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: textDark,
        fontSize: 13,
      ),
    );
  }

  Widget _summaryRow(String title, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(
            "${isDiscount ? '-' : ''}৳${_toBnNum(amount.abs().toStringAsFixed(0))}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red.shade700 : textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodButton({
    required String label,
    required String type,
    required IconData iconData,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => selectedPaymentMethod.value = type,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkGreen.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? darkGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(iconData, color: isSelected ? darkGreen : Colors.grey.shade600, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? darkGreen : textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: bgCream,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    lang.isBangla ? "চেকআউট" : "Checkout",
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textDark, size: 22),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            )),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ADDRESS & ITEMS SECTION
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Obx(() {
                            return Container(
                              height: 195,
                              padding: const EdgeInsets.all(10),
                              decoration: _cardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _sectionHeader(lang.isBangla ? "১. ঠিকানা" : "1. Address"),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.add_circle_outline, color: darkGreen, size: 18),
                                        onPressed: () => Get.to(() => const AddAddressPage()),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (address.addresses.isEmpty && !address.isLoading.value)
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          lang.isBangla ? "কোন ঠিকানা পাওয়া যায়নি" : "No Address Found",
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Scrollbar(
                                        controller: _addressScrollController,
                                        child: ListView.builder(
                                          controller: _addressScrollController,
                                          padding: EdgeInsets.zero,
                                          itemCount: address.addresses.length,
                                          itemBuilder: (context, index) {
                                            final addr = address.addresses[index];
                                            return Obx(() {
                                              final isSelected = address.selectedAddress.value?.id == addr.id;
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 6),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? darkGreen.withOpacity(0.06) : Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: isSelected ? darkGreen : Colors.grey.shade300,
                                                    width: isSelected ? 1.5 : 1,
                                                  ),
                                                ),
                                                child: RadioListTile<String>(
                                                  value: addr.id,
                                                  groupValue: address.selectedAddress.value?.id,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                                                  dense: false,
                                                  activeColor: darkGreen,
                                                  onChanged: (val) {
                                                    if (val != null) address.selectAddress(addr);
                                                  },
                                                  title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          addr.fullName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                            color: textDark,
                                                          ),
                                                        ),
                                                      ),
                                                      _buildAddressMenu(addr),
                                                    ],
                                                  ),
                                                  subtitle: Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Text(
                                                      "${addr.areaOrVillage}, ${addr.landmark}",
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: textDark.withOpacity(0.8),
                                                      ),
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
                        const SizedBox(width: 8),

                        Expanded(
                          flex: 1,
                          child: Obx(() {
                            return Container(
                              height: 195,
                              padding: const EdgeInsets.all(10),
                              decoration: _cardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader(lang.isBangla ? "২. আপনার আইটেম" : "2. Your Items"),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: cart.cartItems.length,
                                      itemBuilder: (context, index) {
                                        final item = cart.cartItems[index];

                                        // ইউনিট বের করার লজিক
                                        dynamic unitValue;
                                        try {
                                          unitValue = (item as dynamic).unit ?? (item as dynamic).unitValue ?? (item as dynamic).weight;
                                        } catch (_) {
                                          unitValue = null;
                                        }
                                        String unitText = unitValue != null && unitValue.toString().isNotEmpty 
                                            ? " (${unitValue.toString()})" 
                                            : "";

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6.0),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: Image.network(
                                                  item.image,
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) => Container(color: Colors.grey, width: 30, height: 30),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${item.localizedTitle}$unitText",
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: textDark),
                                                    ),
                                                    Text(
                                                      "৳${_toBnNum(item.price.toStringAsFixed(0))} x ${_toBnNum(item.quantity.toString())}",
                                                      style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
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
                                  const Divider(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(lang.isBangla ? "সাবটোটাল:" : "Subtotal:", style: TextStyle(fontSize: 10, color: textDark)),
                                      Text(
                                        "৳${_toBnNum(getSubtotal().toStringAsFixed(0))}",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: textDark),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // REWARD WALLET SECTION
                    Obx(() {
                      double maxAllowedReward = math.min(
                        order.walletBalance.value.toDouble(),
                        getMaxDiscount(),
                      );

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: _cardDecoration(
                          borderColor: accentGold.withOpacity(0.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: accentGold.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(Icons.card_giftcard, color: accentGold, size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    _sectionHeader(lang.isBangla ? "রিওয়ার্ড ওয়ালেট" : "Reward Wallet"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "৳${_toBnNum(order.walletBalance.value.toStringAsFixed(0))}",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Transform.scale(
                                      scale: 0.7,
                                      child: Switch(
                                        activeColor: accentGold,
                                        value: order.useReward.value,
                                        onChanged: (v) {
                                          order.useReward.value = v;
                                          order.rewardAmount.value = v ? maxAllowedReward : 0;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (order.useReward.value) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor: accentGold,
                                        thumbColor: accentGold,
                                        trackHeight: 2,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                        inactiveTrackColor: Colors.grey.shade300,
                                      ),
                                      child: Slider(
                                        value: order.rewardAmount.value.toDouble().clamp(0, maxAllowedReward),
                                        min: 0,
                                        max: maxAllowedReward > 0 ? maxAllowedReward : 1.0,
                                        onChanged: (v) => updateRewardAmount(v),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "-৳${_toBnNum(getReward().toStringAsFixed(0))}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 11),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    // PAYMENT METHOD & SUMMARY
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(lang.isBangla ? "৪. পেমেন্ট পদ্ধতি" : "4. Select Payment Method"),
                          const SizedBox(height: 8),
Obx(() {

  if (!paymentSettings.codEnabled.value &&
      !paymentSettings.sslcommerzEnabled.value) {

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: const Text(
        "No payment method available",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  if (paymentSettings.codEnabled.value &&
      !paymentSettings.sslcommerzEnabled.value &&
      selectedPaymentMethod.value !=
          "COD") {

    selectedPaymentMethod.value =
        "COD";
  }

  if (!paymentSettings.codEnabled.value &&
      paymentSettings.sslcommerzEnabled.value &&
      selectedPaymentMethod.value !=
          "SSLCOMMERZ") {

    selectedPaymentMethod.value =
        "SSLCOMMERZ";
  }

  return Row(
    children: [

      if (paymentSettings.codEnabled.value)
        Expanded(
          child: _paymentMethodButton(
            label: lang.isBangla
                ? "ক্যাশ অন ডেলিভারি"
                : "Cash on Delivery",
            type: "COD",
            iconData:
                Icons.local_shipping,
            isSelected:
                selectedPaymentMethod.value ==
                    "COD",
          ),
        ),

      if (paymentSettings.codEnabled.value &&
          paymentSettings.sslcommerzEnabled.value)
        const SizedBox(width: 8),

      if (paymentSettings.sslcommerzEnabled.value)
        Expanded(
          child: _paymentMethodButton(
            label: lang.isBangla
                ? "অনলাইন পেমেন্ট"
                : "Online Payment",
            type: "SSLCOMMERZ",
            iconData: Icons.payment,
            isSelected:
                selectedPaymentMethod.value ==
                    "SSLCOMMERZ",
          ),
        ),
    ],
  );
}),
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 4),
                          Text(
                            lang.isBangla ? "অর্ডার সারাংশ" : "Order Summary",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            return Column(
                              children: [
                                _summaryRow(lang.isBangla ? "সাবটোটাল" : "Subtotal", getSubtotal()),
                                if (order.useReward.value)
                                  _summaryRow(lang.isBangla ? "রিওয়ার্ড ডিসকাউন্ট" : "Reward Discount", getReward(), isDiscount: true),
                                _summaryRow(lang.isBangla ? "ডেলিভারি চার্জ" : "Delivery Charge", getDelivery()),
                                const Divider(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.isBangla ? "মোট" : "Total",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                                    ),
                                    Text(
                                      "৳${_toBnNum(getTotal().toStringAsFixed(0))}",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkGreen),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // STICKY BOTTOM BUTTON
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
                child: Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                      ),
                      onPressed: order.isLoading.value
                          ? null
                          : () {
                              final selectedAddr = address.selectedAddress.value;
                              if (selectedAddr == null || address.addresses.isEmpty) {
                                Get.snackbar(
                                  lang.isBangla ? "ঠিকানা প্রয়োজন" : "Address Required",
                                  lang.isBangla
                                      ? "দয়া করে আপনার ডেলিভারি ঠিকানা নির্বাচন করুন।"
                                      : "Please select your delivery address.",
                                  backgroundColor: Colors.orange.shade800,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              // কনফার্মেশন পপ-আপ কল
                              _openConfirmationPopup(context, selectedAddr);
                            },
                      child: order.isLoading.value
                          ? const AppLoader()
                          : Text(
                              lang.isBangla
                                  ? "অর্ডার সম্পন্ন করুন (৳${_toBnNum(getTotal().toStringAsFixed(0))})"
                                  : "Place Order (৳${_toBnNum(getTotal().toStringAsFixed(0))})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}