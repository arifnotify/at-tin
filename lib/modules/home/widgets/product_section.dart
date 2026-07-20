import 'package:flutter/material.dart';
import 'package:tin/data/models/product_model.dart';
import 'package:tin/modules/home/widgets/product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox();

    // মেইন স্ক্রিনের দুই পাশের প্যাডিং (১২ + ১২ = ২৪) বাদ দিয়ে বাকি জায়গাটুকু নেওয়া হলো
    final double availableWidth = MediaQuery.of(context).size.width - 24;
    
    // স্ক্রিনশটের মতো ৩টি পুরো এবং ৪ নম্বরটির আংশিক অংশ দেখানোর জন্য ম্যাজিক ক্যালকুলেশন
    final double dynamicCardWidth = availableWidth / 3.25; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // টাইটেল এবং More বাটন সেকশন
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: const Row(
                children: [
                  Text(
                    "More",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff7B3FE4),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: Color(0xff7B3FE4),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 10),

        // হরাইজনটাল প্রোডাক্ট লিস্ট
        SizedBox(
          height: 245, // কার্ডের ভেতরের কন্টেন্ট অনুযায়ী পারফেক্ট ফিক্সড হাইট (ওভারফ্লো মুক্ত)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                cardWidth: dynamicCardWidth, // ডাইনামিক উইডথটি কার্ডের ভেতর পাঠিয়ে দেওয়া হলো
              );
            },
          ),
        ),
      ],
    );
  }
}