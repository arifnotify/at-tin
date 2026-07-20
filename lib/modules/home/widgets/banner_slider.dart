import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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

    // স্ক্রিনের উইডথ অনুযায়ী ডাইনামিক হাইট ক্যালকুলেশন (Overflow এড়াতে)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sliderHeight = screenWidth * 0.45; // রেসপনসিভ অ্যাসপেক্ট রেশিও

    return CarouselSlider(
      options: CarouselOptions(
        height: sliderHeight > 200 ? 200 : sliderHeight, // ম্যাক্সিমাম হাইট কন্ট্রোল
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 0.85, // স্ক্রিনশটের মতো ডানপাশে হালকা পরবর্তী ব্যানার দেখানোর জন্য
        padEnds: false, // বাঁ দিক থেকে সমানভাবে শুরু করার জন্য
      ),
      items: banners.map((banner) {
        return Container(
          margin: const EdgeInsets.only(right: 12), // ব্যানারগুলোর মাঝের গ্যাপ
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              banner.image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}