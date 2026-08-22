import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/flash/flash_sale_controller.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';
import 'package:tin/modules/home/widgets/app_loader.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

class FlashSalePage extends StatefulWidget {
  const FlashSalePage({super.key});

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  final FlashSaleController flashSaleController = Get.put(FlashSaleController());
  final CartController cartController = Get.find<CartController>();
  final LanguageController langController = Get.find<LanguageController>();

  String? bannerImageUrl;
  String? flashSaleTitle;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;

    if (args != null && args is Map) {
      bannerImageUrl = args['imageUrl']?.toString();
      flashSaleTitle = args['title']?.toString();
      final String? flashSaleId = args['id']?.toString();

      if (flashSaleId != null && flashSaleId.isNotEmpty) {
        flashSaleController.fetchFlashSaleById(flashSaleId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Obx(() {
          final bool isBn = langController.currentLanguage.value == 'bn';
          final String title = flashSaleTitle ??
              (flashSaleController.flashSaleTitle.value.isNotEmpty
                  ? flashSaleController.flashSaleTitle.value
                  : (isBn ? "স্বল্প মূল্যের অফার" : "Flash Sale"));
          return Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ),
      body: Obx(() {
        if (flashSaleController.isLoading.value) {
          return const Center(
            child: AppLoader(),
          );
        }

        final List<ProductModel> productsList = flashSaleController.products;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ১. ব্যানার সেকশন
              if (bannerImageUrl != null && bannerImageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    bannerImageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultBanner(langController, flashSaleTitle),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                _buildDefaultBanner(langController, flashSaleTitle),
                const SizedBox(height: 16),
              ],

              /// ২. খালি থাকলে মেসেজ
              if (productsList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      langController.currentLanguage.value == 'bn'
                          ? "এই অফারে কোনো প্রোডাক্ট পাওয়া যায়নি"
                          : "No Product Available for this Flash Sale",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                )
              else
                /// ৩. ৩-কলামের প্রোডাক্ট গ্রিড
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productsList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.50,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: productsList[index],
                    );
                  },
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: AppBottomNavBar(
        cartController: cartController,
      ),
    );
  }

  Widget _buildDefaultBanner(LanguageController langController, String? titleText) {
    final bool isBn = langController.currentLanguage.value == 'bn';
    final String title = titleText ?? (isBn ? "বিশেষ অফারের পণ্যসমূহ" : "Special Offer Products");

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBn ? "সীমিত সময়ের জন্য বিশেষ ছাড়" : "Limited time exclusive deals",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}