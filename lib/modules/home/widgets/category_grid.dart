import 'package:flutter/material.dart';
import 'package:tin/data/models/category_model.dart';

class CategoryGrid
    extends StatelessWidget {

  final List<CategoryModel>
      categories;

  const CategoryGrid({
    super.key,
    required this.categories,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return GridView.builder(

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount:
          categories.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
      ),

      itemBuilder:
          (
        context,
        index,
      ) {

        final category =
            categories[index];

        return Card(

          child: Center(
            child: Text(
              category.name,
            ),
          ),
        );
      },
    );
  }
}