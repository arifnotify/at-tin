import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/modules/auth/auth_controller.dart';
import 'package:tin/modules/auth/login_page.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/location/location_controller.dart';
import 'package:tin/modules/order/order_summary_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final cartController = Get.find<CartController>();
    final authController = Get.find<AuthController>();

    // ভাষা কন্ট্রোলার
    final lang = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController());

    final Color primaryThemeColor = const Color(0xFF1D4D33); // ব্র্যান্ড থিম কালার

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isLoggedIn.value) {
        cartController.loadServerCart();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Get.back(),
        ),
        title: Text(
          lang.isBangla ? "শপিং ব্যাগ" : "Shopping Bag",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Obx(() {
        final isEmpty = cartController.cartItems.isEmpty;
        final isLoading = cartController.isLoading.value;

        return Stack(
          children: [
            // ১. খালি কার্ট ভিউ
            if (isEmpty && !isLoading)
              _EmptyCartView(isBangla: lang.isBangla),

            // ২. কার্ট কন্টেন্ট
            if (!isEmpty)
              Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: cartController.cartItems.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 24,
                      ),
                      itemBuilder: (context, index) {
                        final item = cartController.cartItems[index];
                        return _CartItemTile(
                          item: item,
                          index: index,
                          cartController: cartController,
                          authController: authController,
                          themeColor: primaryThemeColor, 
                          lang: lang,
                        );
                      },
                    ),
                  ),

                  // ডেলিভারি ফি ব্যানার
                  _DeliveryFeeBanner(
                    deliveryCharge: locationController.deliveryCharge.value,
                    isBangla: lang.isBangla,
                  ),

                  // বটম চেকআউট বার
                  _BottomCheckoutBar(
                    cartController: cartController,
                    authController: authController,
                    themeColor: primaryThemeColor,
                    isBangla: lang.isBangla,
                  ),
                ],
              ),

            // ৩. প্রথমবার লোডিং স্টেট
            if (isLoading && isEmpty)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(child: AppLoader()),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ==========================================
// PRIVATE SUB-WIDGETS (ফর বেটার পারফর্মেন্স)
// ==========================================

class _EmptyCartView extends StatelessWidget {
  final bool isBangla;
  const _EmptyCartView({required this.isBangla});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            isBangla ? "আপনার কার্ট খালি" : "Your cart is empty",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final int index;
  final CartController cartController;
  final AuthController authController;
  final Color themeColor;
  final LanguageController lang;

  const _CartItemTile({
    required this.item,
    required this.index,
    required this.cartController,
    required this.authController,
    required this.themeColor,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // প্রোডাক্ট ইমেজ
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            item.image,
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // প্রোডাক্ট বিবরণ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.localizedTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "৳${item.price}",
                    style: const TextStyle(
                      color: Color(0xffE55C5C),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "৳${(item.price * 1.2).toStringAsFixed(0)}",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 6),
                  
                  // ডায়নামিক ইউনিট সেফ রেন্ডারিং
                    // অ্যাপ ড্রয়ারের মতো ডাইনামিক ইউনিট দেখানোর জন্য
                    Builder(
                      builder: (context) {
                        final unitText = item.localizedUnit; // সরাসরি মডেলের গেটার কল করা হলো

                        if (unitText.isEmpty) return const SizedBox();

                        return Text(
                          "| $unitText",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),

        // কোয়ান্টিটি কন্ট্রোলার
// কোয়ান্টিটি কন্ট্রোলার
Row(
  children: [
    _QuantityBtn(
      icon: Icons.remove,
      color: themeColor,
      onTap: () {
        // সব ক্ষেত্রেই Controller-এর মেথড ব্যবহার করুন
        cartController.decrement(item.id);
      },
    ),
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(minWidth: 32),
      alignment: Alignment.center,
      // Quantity টেক্সটকে Obx দিয়ে মুড়ে দিন (নিরাপদ)
      child: Obx(() {
        final currentItem = cartController.getItem(item.id);
        return Text(
          (currentItem?.quantity ?? item.quantity).toString(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        );
      }),
    ),
    _QuantityBtn(
      icon: Icons.add,
      color: themeColor,
      onTap: () {
        cartController.increment(item.id);
      },
    ),
  ],
),
      ],
    );
  }
}

class _QuantityBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuantityBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _DeliveryFeeBanner extends StatelessWidget {
  final dynamic deliveryCharge;
  final bool isBangla;

  const _DeliveryFeeBanner({
    required this.deliveryCharge,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xffF0F9F4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xff1AA360), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBangla ? "ডেলিভারি চার্জ: ৳$deliveryCharge" : "Delivery fee: ৳$deliveryCharge",
              style: const TextStyle(
                color: Color(0xff1AA360),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCheckoutBar extends StatelessWidget {
  final CartController cartController;
  final AuthController authController;
  final Color themeColor;
  final bool isBangla;

  const _BottomCheckoutBar({
    required this.cartController,
    required this.authController,
    required this.themeColor,
    required this.isBangla,
  });

  void _navigateToNext() {
    if (authController.isLoggedIn.value) {
      Get.to(() => const OrderSummaryPage());
    } else {
      Get.to(() => LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: _navigateToNext,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // মোট আইটেম সংকেত
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cartController.totalItems.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // টেক্সট
                Expanded(
                  child: Text(
                    isBangla ? "ঠিকানা রিভিউ করুন" : "Review Address",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // গ্র্যান্ড টোটাল
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "৳${cartController.grandTotal.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}