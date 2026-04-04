import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/sized_context.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/check_device_size.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:grad_store_app/features/offers/presentation/state/offers_provider.dart';
import '../bloc/banner_slider_cubit.dart';

class BannerSliderWidget extends StatelessWidget {
  const BannerSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BannerSliderCubit>(
      create: (context) => BannerSliderCubit(),
      child: const _BannerSliderWidget(),
    );
  }
}

class _BannerSliderWidget extends StatelessWidget {
  const _BannerSliderWidget();

  @override
  Widget build(BuildContext context) {
    final watch = context.watch<BannerSliderCubit>();
    final read = context.read<BannerSliderCubit>();
    final colors = context.theme.appColors;
    
    return Consumer<OffersProvider>(
      builder: (context, provider, child) {
        if (provider.status == OffersStatus.loading) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final offers = provider.items;
        if (offers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Center(
          child: SizedBox(
            width:
                checkDesktopSize(context)
                    ? Dimens.largeDeviceBreakPoint
                    : context.widthPx,
            child: Column(
              spacing: Dimens.padding,
              children: [
                CarouselSlider(
                  carouselController: watch.state.controller,
                  items:
                      offers.map((offer) {
                        final imageUrl = offer.mainImage ?? offer.productImage;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.largePadding,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl.startsWith('http') 
                                      ? imageUrl 
                                      : '${ApiConstants.baseUrl}$imageUrl',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                                  )
                                : Container(color: Colors.grey[300]),
                          ),
                        );
                      }).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.5,
                    aspectRatio: 2.3,
                    viewportFraction: 1,
                    onPageChanged: (final index, final reason) {
                      read.onPageChanged(index: index);
                    },
                  ),
                ),
                AnimatedSmoothIndicator(
                  activeIndex: watch.state.currentIndex % offers.length,
                  count: offers.length,
                  effect: WormEffect(
                    activeDotColor: colors.primary,
                    dotColor: colors.gray,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 4,
                    type: WormType.normal,
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
