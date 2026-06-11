import 'package:flutter/material.dart';
import 'package:tin/data/models/category_model.dart';

class CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final VoidCallback? onAllCategoriesPressed;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.onAllCategoriesPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45, // ছবির মতো অনুপাত
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Category Image
                  Image.network(
                    category.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),

                  // Gradient Overlay (নাম স্পষ্ট দেখার জন্য)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),

                  // Category Name (ইমেজের উপর)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // All Categories Button (ছবির মতো)
        Center(
          child: TextButton(
            onPressed: onAllCategoriesPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text("All Categories"),
          ),
        ),
      ],
    );
  }
}