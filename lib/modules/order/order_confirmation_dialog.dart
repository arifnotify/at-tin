import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final dynamic selectedAddr;
  final String paymentMethod;
  final double subtotal;
  final double rewardDiscount;
  final double deliveryCharge;
  final double total;
  final VoidCallback onConfirm;

  const OrderConfirmationDialog({
    super.key,
    required this.selectedAddr,
    required this.paymentMethod,
    required this.subtotal,
    required this.rewardDiscount,
    required this.deliveryCharge,
    required this.total,
    required this.onConfirm,
  });

  String _toBnNum(String number, bool isBangla) {
    if (!isBangla) return number;
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < englishDigits.length; i++) {
      number = number.replaceAll(englishDigits[i], banglaDigits[i]);
    }
    return number;
  }

  // প্রডাক্টের ইউনিট বের করার সেফ লজিক
  String _getItemUnit(dynamic item) {
    try {
      // আপনার প্রডাক্ট/কার্ট মডেলে ইউনিট যে ফিল্ডে আছে সেটা রিড করবে
      if (item.unit != null && item.unit.toString().isNotEmpty) {
        return item.unit.toString();
      }
      if (item.unitValue != null && item.unitValue.toString().isNotEmpty) {
        return item.unitValue.toString();
      }
      if (item.weight != null && item.weight.toString().isNotEmpty) {
        return item.weight.toString();
      }
      if (item.product != null && item.product.unit != null) {
        return item.product.unit.toString();
      }
    } catch (_) {}
    return '';
  }

  Widget _summaryRow(String title, double amount, bool isBangla, {bool isDiscount = false, Color? textDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(
            "${isDiscount ? '-' : ''}৳${_toBnNum(amount.abs().toStringAsFixed(0), isBangla)}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red.shade700 : (textDark ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final lang = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController());

    const Color cardColor = Color(0xFFFCFAF2);
    const Color darkGreen = Color(0xFF1D4D33);
    const Color textDark = Color(0xFF2C2520);
    final bool isBangla = lang.isBangla;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: darkGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: darkGreen, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isBangla ? "অর্ডার নিশ্চিতকরণ" : "Confirm Your Order",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBangla
                          ? "অনুগ্রহ করে আপনার প্রোডাক্টের পরিমাণ, ইউনিট ও ঠিকানা চেক করে চূড়ান্ত অর্ডার নিশ্চিত করুন।"
                          : "Please check your item quantities, units, and address before confirming.",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Main Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Address
                    Text(
                      isBangla ? "ডেলিভারি ঠিকানা:" : "Delivery Address:",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "${selectedAddr.fullName}\n${selectedAddr.areaOrVillage}, ${selectedAddr.landmark}",
                        style: TextStyle(fontSize: 11, color: textDark.withOpacity(0.9), height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Product Items List
                    Text(
                      isBangla ? "আইটেমসমূহ (${cart.cartItems.length} টি):" : "Items (${cart.cartItems.length}):",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 6),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.cartItems.length,
                      separatorBuilder: (c, i) => const Divider(height: 10),
                      itemBuilder: (context, index) {
                        final item = cart.cartItems[index];
                        final String unit = _getItemUnit(item);

                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item.image,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(color: Colors.grey.shade300, width: 38, height: 38),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title + Unit Display
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.localizedTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: textDark,
                                          ),
                                        ),
                                      ),
                                      if (unit.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: darkGreen.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            unit,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${isBangla ? 'পরিমাণ' : 'Qty'}: ${_toBnNum(item.quantity.toString(), isBangla)}  |  ৳${_toBnNum(item.price.toStringAsFixed(0), isBangla)}",
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "৳${_toBnNum((item.price * item.quantity).toStringAsFixed(0), isBangla)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textDark),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    // Price Breakdown
                    _summaryRow(isBangla ? "সাবটোটাল" : "Subtotal", subtotal, isBangla, textDark: textDark),
                    if (rewardDiscount > 0)
                      _summaryRow(isBangla ? "রিওয়ার্ড ডিসকাউন্ট" : "Reward Discount", rewardDiscount, isBangla, isDiscount: true, textDark: textDark),
                    _summaryRow(isBangla ? "ডেলিভারি চার্জ" : "Delivery Charge", deliveryCharge, isBangla, textDark: textDark),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBangla ? "পেমেন্ট পদ্ধতি" : "Payment Method",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                        Text(
                          paymentMethod == 'COD'
                              ? (isBangla ? "ক্যাশ অন ডেলিভারি" : "Cash on Delivery")
                              : (isBangla ? "অনলাইন পেমেন্ট" : "Online Payment"),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBangla ? "সর্বমোট প্রদেয়" : "Total Payable",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark),
                        ),
                        Text(
                          "৳${_toBnNum(total.toStringAsFixed(0), isBangla)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      isBangla ? "পরিবর্তন করুন" : "Cancel",
                      style: const TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Text(
                      isBangla ? "হ্যাঁ, ওকে" : "Confirm Order",
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}