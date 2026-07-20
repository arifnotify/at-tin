import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/modules/address/address_page.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>().isLoggedIn.value) {
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
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Shopping Bag",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            // =====================
            // EMPTY CART
            // =====================
            if (cartController.cartItems.isEmpty && !cartController.isLoading.value)
              const Center(
                child: Text(
                  "Your cart is empty",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // =====================
            // CART CONTENT (HIGH PERFORMANCE UI)
            // =====================
            if (cartController.cartItems.isNotEmpty)
              Column(
                children: [
                  // CART ITEMS LIST
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: cartController.cartItems.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 24,
                      ),
                      itemBuilder: (context, index) {
                        final item = cartController.cartItems[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item.image,
                                width: 55,
                                height: 55,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Details
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
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Active Offer Price
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
                                      
                                      Text(
                                        "| 1 kg", 
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // INSTANT RESPONSE QUANTITY CONTROLLER
                            Row(
                              children: [
                                // Minus Button (Instant Update)
                                GestureDetector(
                                  onTap: () {
                                    final auth = Get.find<AuthController>();
                                    if (auth.isLoggedIn.value) {
                                      if (item.quantity > 1) {
                                        // ১. সাথে সাথে লোকাল স্টেট কমিয়ে দিচ্ছি (No Lag!)
                                        item.quantity--;
                                        cartController.cartItems.refresh();
                                        // ২. ব্যাকগ্রাউন্ডে ডাটাবেজে হিট করবে
                                        cartController.decreaseServerQty(
                                          item.cartId!,
                                          item.quantity + 1, // আগের কোয়ান্টিটি পাস করে সেভ হ্যান্ডেল করার জন্য
                                        );
                                      } else {
                                        // ১ পিস থাকলে ডিলিট মেথড কল হবে
                                        cartController.cartService.removeItem(item.cartId!);
                                        cartController.cartItems.removeAt(index);
                                      }
                                    } else {
                                      cartController.decrement(item.id);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    size: 22,
                                    color: Color(0xff9E65FA),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Quantity Indicator Box
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 32),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Plus Button (Instant Update)
                                GestureDetector(
                                  onTap: () {
                                    final auth = Get.find<AuthController>();
                                    if (auth.isLoggedIn.value) {
                                      // ১. সাথে সাথে লোকাল স্টেট বাড়িয়ে দিচ্ছি (Instant UI feedback)
                                      item.quantity++;
                                      cartController.cartItems.refresh();
                                      // ২. ব্যাকগ্রাউন্ডে ডাটাবেজ আপডেট হবে
                                      cartController.increaseServerQty(
                                        item.cartId!,
                                        item.quantity - 1, // আগের কোয়ান্টিটি রেফারেন্স হিসেবে পাস করা
                                      );
                                    } else {
                                      cartController.increment(item.id);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    size: 22,
                                    color: Color(0xff9E65FA),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Green Info Banner
                  Container(
                    width: double.infinity,
                    color: const Color(0xffF0F9F4),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xff1AA360),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Delivery fee: ৳${locationController.deliveryCharge.value}",
                            style: const TextStyle(
                              color: Color(0xff1AA360),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Button Container (Instant Total Calculation)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xff9E65FA), 
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            // Item count
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
                            
                            // Middle Text Area
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final auth = Get.find<AuthController>();
                                  if (auth.isLoggedIn.value) {
                                    Get.to(() => const OrderSummaryPage());
                                  } else {
                                    Get.to(() => LoginPage());
                                  }
                                },
                                child: const Text(
                                  "Review Address",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Grand Total Button (Automatically updates instantly on UI change)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () {
                                  final auth = Get.find<AuthController>();
                                  if (auth.isLoggedIn.value) {
                                    Get.to(() => const OrderSummaryPage());
                                  } else {
                                    Get.to(() => LoginPage());
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff7D4FD4), 
                                    borderRadius: BorderRadius.circular(12),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // =====================
            // NO BLOCKING LOADER FOR QUANTITY UPDATE
            // =====================
            // শুধুমাত্র ফার্স্ট টাইম ফুল স্ক্রিন লোড হলে বা ডিলিট হলে লোডার দেখাবো, বাটন ক্লিকে নয়।
            if (cartController.isLoading.value && cartController.cartItems.isEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withOpacity(.45),
                    child: const Center(
                      child: AppLoader(),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}