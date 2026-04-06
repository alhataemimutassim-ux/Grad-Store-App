import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/check_device_size.dart';
import '../state/slider_provider.dart';
import '../../domain/entities/slider_image.dart';

class MainSliderWidget extends StatefulWidget {
  const MainSliderWidget({super.key});

  @override
  State<MainSliderWidget> createState() => _MainSliderWidgetState();
}

class _MainSliderWidgetState extends State<MainSliderWidget> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SliderProvider>().fetchSliders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;

    return Consumer<SliderProvider>(
      builder: (context, provider, child) {
        if (provider.status == SliderStatus.loading) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.sliders.isEmpty) {
          return const SizedBox.shrink(); // لا يظهر شيء إذا لم تتوفر صور
        }

        return Center(
          child: SizedBox(
            width: checkDesktopSize(context)
                ? Dimens.largeDeviceBreakPoint
                : context.widthPx, // عرض كامل
            child: Column(
              children: [
                CarouselSlider(
                  carouselController: _controller,
                  items: provider.sliders.map((slider) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _SliderCard(slider: slider),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    enlargeCenterPage: true, // يجعل الصورة في المنتصف بارزة
                    enlargeFactor: 0.15, // نعومة التكبير
                    aspectRatio: 2.2, // تناسب طولي وعرضي لافتة ممتازة
                    viewportFraction: 0.9, // تظهر أطراف الصور الأخرى
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSmoothIndicator(
                  activeIndex: _currentIndex,
                  count: provider.sliders.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: colors.primary,
                    dotColor: colors.gray.withValues(alpha: 0.5),
                    dotHeight: 6,
                    dotWidth: 6,
                    expansionFactor: 3,
                    spacing: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliderCard extends StatelessWidget {
  final SliderImage slider;

  const _SliderCard({required this.slider});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    // التأكد من أن الرابط سليم ومتكامل حتى لو كان من السيرفر كمسار نسبي (نفتحه كمسار كامل)
    final imageUrl = slider.imageUrl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            // تدرج لوني أسود خفيف بالأسفل إذا أردنا إبراز النص
            if (slider.title.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Text(
                  slider.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
