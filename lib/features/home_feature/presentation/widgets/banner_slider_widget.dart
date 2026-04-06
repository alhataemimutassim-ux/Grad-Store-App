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
import 'package:grad_store_app/features/offers/domain/entities/offer.dart';
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: OfferCard(offer: offer),
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

class OfferCard extends StatelessWidget {
  final Offer offer;

  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final imageUrl = offer.mainImage ?? offer.productImage;
    final fullUrl = imageUrl != null && imageUrl.isNotEmpty 
      ? (imageUrl.startsWith('http') ? imageUrl : '${ApiConstants.imageBaseUrl}$imageUrl')
      : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (fullUrl != null)
              Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
              )
            else
              Container(color: Colors.grey[300]),

            // Gradient Overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // Offer Details
            Positioned(
              bottom: 12,
              right: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          offer.productName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (offer.discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "خصم ${offer.discount.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Countdown Timer
                  if (offer.endDateTime != null && offer.endDateTime!.isAfter(DateTime.now()))
                    CountdownTimerWidget(endTime: offer.endDateTime!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CountdownTimerWidget extends StatefulWidget {
  final DateTime endTime;
  const CountdownTimerWidget({super.key, required this.endTime});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration _timeLeft;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
  }

  void _updateTimeLeft() {
    if (!mounted) return;
    setState(() {
      _timeLeft = widget.endTime.difference(DateTime.now());
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
        _isExpired = true;
      }
    });

    if (!_isExpired) {
      Future.delayed(const Duration(seconds: 1), _updateTimeLeft);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpired) {
      return const Text(
        "انتهى العرض",
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      );
    }

    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours.remainder(24);
    final minutes = _timeLeft.inMinutes.remainder(60);
    final seconds = _timeLeft.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        _buildTimeBox(days.toString().padLeft(2, '0'), "يوم"),
        const Text(" : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        _buildTimeBox(hours.toString().padLeft(2, '0'), "ساعة"),
        const Text(" : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        _buildTimeBox(minutes.toString().padLeft(2, '0'), "دقيقة"),
        const Text(" : ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        _buildTimeBox(seconds.toString().padLeft(2, '0'), "ثانية"),
      ],
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.5),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 8),
        ),
      ],
    );
  }
}
