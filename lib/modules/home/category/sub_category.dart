import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tin/data/models/category_model.dart';
import 'package:tin/data/services/category_service.dart';

class SubCategoryPage extends StatelessWidget {
  SubCategoryPage({super.key});

  final service = CategoryService();

  @override
  Widget build(BuildContext context) {
    final CategoryModel category = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: FutureBuilder(
        future: service.getSubCategories(category.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as List;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final sub = data[index];

              return ListTile(
                leading: Image.network(sub["image"] ?? ""),
                title: Text(sub["name"] ?? ""),
                onTap: () {
                  // next: products page
                },
              );
            },
          );
        },
      ),
    );
  }
}