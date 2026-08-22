import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/core/routes/app_routes.dart';
import 'package:tin/data/models/banner_model.dart';

class BannerSlider extends StatelessWidget {
  final List<BannerModel> banners;

  const BannerSlider({
    super.key,
    required this.banners,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox();
    }

    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final bool isBangla = languageController.isBangla;

      final double screenWidth = MediaQuery.of(context).size.width;
      final double sliderHeight = screenWidth * 0.45;

      return CarouselSlider(
        options: CarouselOptions(
          height: sliderHeight > 200 ? 200 : sliderHeight,
          autoPlay: true,
          enlargeCenterPage: false,
          viewportFraction: 0.85,
          padEnds: false,
        ),
        items: banners.map((banner) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    print('========================');
                    print('BANNER CLICKED');
                    print('TITLE: ${banner.title}');
                    print('TYPE: ${banner.linkType}');
                    print('FLASH SALE ID (linkId): ${banner.linkId}');
                    print('========================');

                    // 1. Flash Sale
                    if (banner.linkType == 'flashSale') {
                      if (banner.linkId == null || banner.linkId!.isEmpty) {
                        Get.snackbar(
                          isBangla ? 'ত্রুটি' : 'Error',
                          isBangla
                              ? 'ফ্ল্যাশ সেলের আইডি পাওয়া যায়নি'
                              : 'Flash Sale ID not found',
                        );
                        return;
                      }

                      Get.toNamed(
                        AppRoutes.flashSale,
                        arguments: {
                          'id': banner.linkId,
                          'title': banner.title,
                          'imageUrl': banner.image,
                        },
                      );
                    }

                    // 2. Single Product
                    else if (banner.linkType == 'product') {
                      if (banner.linkId == null || banner.linkId!.isEmpty) {
                        Get.snackbar(
                          isBangla ? 'ত্রুটি' : 'Error',
                          isBangla
                              ? 'পণ্যের আইডি পাওয়া যায়নি'
                              : 'Product ID not found',
                        );
                        return;
                      }

                      Get.toNamed(
                        AppRoutes.productDetails,
                        arguments: banner.linkId,
                      );
                    }

                    // 3. Category
                    else if (banner.linkType == 'category') {
                      if (banner.linkId == null || banner.linkId!.isEmpty) {
                        Get.snackbar(
                          isBangla ? 'ত্রুটি' : 'Error',
                          isBangla
                              ? 'ক্যাটাগরির আইডি পাওয়া যায়নি'
                              : 'Category ID not found',
                        );
                        return;
                      }

                      Get.toNamed(
                        AppRoutes.subCategory,
                        arguments: banner.linkId,
                      );
                    }

                    // 4. No Link
                    else {
                      Get.snackbar(
                        isBangla ? 'তথ্য' : 'Info',
                        isBangla
                            ? 'এই ব্যানারে কোনো অ্যাকশন নির্ধারণ করা হয়নি'
                            : 'No action assigned to this banner',
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      // Banner Image
                      Image.network(
                        banner.image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),

                      // Dark Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.35),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Shop Now Button
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isBangla ? 'কিনুন' : 'Shop Now',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}