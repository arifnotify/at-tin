import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double? cardWidth;

  const ProductCard({
    super.key,
    required this.product,
    this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final lang = Get.find<LanguageController>();

    final currentPrice = product.currentPrice;
    final hasDiscount = product.hasDiscount;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.productDetails,
          arguments: product,
        );
      },
      child: Container(
        width: cardWidth ?? 145, 
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        color: Colors.transparent, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ১. ইমেজ সেকশন + কার্ট বাটন (Stack)
            SizedBox(
              height: 120, 
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Image.network(
                        product.images.isNotEmpty ? product.images.first : "",
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),

                  /// ফ্ল্যাশ সেল ব্যাজ
                  if (product.isFlashSale)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D4D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Obx(() {
                          return Text(
                            lang.currentLanguage.value == "bn" ? "স্বল্প মূল্যে" : "FLASH",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                      ),
                    ),

                  /// কার্ট বাটন এবং প্লাস-মাইনাস কন্ট্রোলার লেয়ার
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Obx(() {
                      final item = cartController.getItem(product.id);

                      if (item == null) {
                        return Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () => cartController.addToCart(product),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xff7B3FE4),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 22,
                                color: Color(0xff7B3FE4),
                              ),
                            ),
                          ),
                        );
                      }

                      if (!item.isEditing) {
                        return Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () => cartController.showControls(product.id),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff7B3FE4),
                              ),
                              child: Center(
                                child: Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        height: 36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xff7B3FE4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                ),
                                onTap: () => cartController.decrement(product.id),
                                child: const Center(
                                  child: Icon(Icons.remove, size: 18, color: Color(0xff7B3FE4)),
                                ),
                              ),
                            ),
                            Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                                onTap: () => cartController.increment(product.id),
                                child: const Center(
                                  child: Icon(Icons.add, size: 18, color: Color(0xff7B3FE4)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// ২. প্রাইস সেকশন
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "৳${currentPrice.toInt()}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffFF6B6B),
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 4),
                  Text(
                    "৳${product.price.toInt()}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),

            /// ৩. প্রোডাক্ট টাইটেল সেকশন (SizedBox দিয়ে সর্বোচ্চ ২ লাইনের ফিক্সড স্পেস রাখা হয়েছে)
            SizedBox(
              height: 38, // ২ লাইনের টেক্সটের জন্য স্ট্যান্ডার্ড ফিক্সড হাইট
              child: Text(
                lang.isBangla ? product.titleBn : product.titleEn,
                maxLines: 2, 
                overflow: TextOverflow.ellipsis, 
                style: const TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.w500, 
                  color: Color(0xFF2D2D2D),
                  height: 1.25, 
                ),
              ),
            ),

            const SizedBox(height: 4), // টাইটেল এবং টাইপের মাঝখানে সামান্য গ্যাপ

            /// ৪. বটম ইউনিট এবং টাইপ/এক্সপায়ারি টেক্সট
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.unit?.isNotEmpty == true ? product.unit! : "1 pcs",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(width: 4), 
                
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.productType == "fresh" ? Icons.shutter_speed_outlined : Icons.event_available,
                          size: 12,
                          color: product.productType == "fresh" ? Colors.green.shade600 : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            product.productType == "fresh" 
                                ? (product.freshText ?? "1 hrs") 
                                : (product.expiryText ?? ""),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: product.productType == "fresh" ? Colors.green.shade600 : Colors.orange.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}