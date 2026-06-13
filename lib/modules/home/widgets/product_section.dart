import 'package:flutter/material.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

class ProductSection
    extends StatelessWidget {

  final String title;

  final List<ProductModel>
      products;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Column(

      children: [

        Row(

          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

          children: [

            Text(
              title,
            ),

            const Text(
              "More >",
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        SizedBox(

          height: 280,

          child:
              ListView.builder(

                  scrollDirection:
                      Axis.horizontal,

                  itemCount:
                      products.length,

                  itemBuilder: (context,index,) {
                     return ProductCard(product:
                          products[index],
                    );
                  },
                )
        ),
      ],
    );
  }
}