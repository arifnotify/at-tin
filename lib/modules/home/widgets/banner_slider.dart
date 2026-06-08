import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tin/data/models/banner_model.dart';


class BannerSlider
    extends StatelessWidget {
  final List<BannerModel>
      banners;

  const BannerSlider({
    super.key,
    required this.banners,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (banners.isEmpty) {
      return const SizedBox();
    }

    return CarouselSlider(
      options:
          CarouselOptions(
        height: 180,
        autoPlay: true,
        viewportFraction: 1,
      ),

      items:
          banners.map(
        (banner) {
          return Container(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 4,
            ),

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              child: Image.network(
                banner.image,
                width:
                    double.infinity,
                fit: BoxFit.cover,

                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color:
                        Colors.grey
                            .shade200,
                    child: const Center(
                      child: Icon(
                        Icons
                            .broken_image,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}