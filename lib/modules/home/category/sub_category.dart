import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tin/controller/language_controller.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/modules/cart/cart_controller.dart';
import 'package:tin/modules/home/category/category_controller.dart';
import 'package:tin/modules/home/category/products_page.dart';
import 'package:tin/modules/home/widgets/app_bottom_nav_bar.dart';

class SubCategoryPage extends StatefulWidget {
  const SubCategoryPage({super.key});

  @override
  State<SubCategoryPage> createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  final CategoryController controller = Get.isRegistered<CategoryController>()
      ? Get.find<CategoryController>()
      : Get.put(CategoryController());

  final CartController cartController = Get.find<CartController>();
  final LanguageController langController = Get.isRegistered<LanguageController>()
      ? Get.find<LanguageController>()
      : Get.put(LanguageController());

  String categoryId = "";
  dynamic initialAppBarTitleName = "Sub Category";

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args != null) {
      if (args is CategoryModel) {
        initialAppBarTitleName = args.name;
        categoryId = args.id;
      } else if (args is Map) {
        initialAppBarTitleName = args["name"] ?? "Sub Category";
        categoryId = args["id"]?.toString() ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> bgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFFFF3E0),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F2F1),
      const Color(0xFFFCE4EC),
    ];

    return Obx(() {
      final currentLang = langController.currentLanguage.value;
      
      String displayAppBarTitle = "Sub Category";
      if (initialAppBarTitleName is Map) {
        displayAppBarTitle = initialAppBarTitleName[currentLang] ?? initialAppBarTitleName["en"] ?? "Sub Category";
      } else if (initialAppBarTitleName != null) {
        displayAppBarTitle = initialAppBarTitleName.toString();
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text(
            displayAppBarTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: categoryId.isEmpty
            ? const Center(child: Text("Invalid Category"))
            : () {
                final subCategories = controller.getSubCategoriesById(categoryId);

                if (subCategories.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Sub Categories Found",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: subCategories.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final sub = subCategories[index];
                    final backgroundColor = bgColors[index % bgColors.length];

                    return GestureDetector(
                      onTap: () {
                        // চেক করা হচ্ছে এই সাব-ক্যাটাগরির ভেতরে আরও সাব-ক্যাটাগরি আছে কি না
                        final nestedSubs = controller.getSubCategoriesById(sub.id);

                        if (nestedSubs.isNotEmpty) {
                          // যদি আরও সাব-ক্যাটাগরি থাকে, তবে আবার SubCategoryPage ওপেন করবে
                          Get.to(
                            () => const SubCategoryPage(),
                            arguments: sub,
                          );
                        } else {
                          // যদি আর সাব-ক্যাটাগরি না থাকে, তবে সরাসরি ProductsPage-এ নিয়ে যাবে
                          Get.to(
                            () => ProductsPage(
                              title: sub.localizedName,
                              products: const [],
                            ),
                            arguments: sub,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Positioned(
                                  left: 10,
                                  top: 0,
                                  bottom: 0,
                                  width: constraints.maxWidth * 0.46,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      sub.localizedName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  bottom: 4,
                                  width: constraints.maxWidth * 0.48,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: sub.image,
                                        fit: BoxFit.contain,
                                        memCacheWidth: 200,
                                        memCacheHeight: 200,
                                        fadeInDuration: const Duration(milliseconds: 300),
                                        placeholder: (context, url) => Container(
                                          color: Colors.transparent,
                                        ),
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }(),
        bottomNavigationBar: AppBottomNavBar(
          cartController: cartController,
        ),
      );
    });
  }
}