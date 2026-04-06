import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/features/offers/domain/entities/offer.dart';
import 'package:grad_store_app/features/offers/presentation/state/offers_provider.dart';
import 'package:grad_store_app/features/home_feature/presentation/screens/product_details_screen.dart';

/// قسم العروض المؤقتة — بطاقات أفقية مع عداد تنازلي حي
class FlashOffersSection extends StatefulWidget {
  const FlashOffersSection({super.key});

  @override
  State<FlashOffersSection> createState() => _FlashOffersSectionState();
}

class _FlashOffersSectionState extends State<FlashOffersSection> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // جلب العروض إذا لم تُحمَّل بعد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<OffersProvider>();
      if (p.status == OffersStatus.initial) p.fetchPublicOffers();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OffersProvider>(
      builder: (context, provider, _) {
        // حالة التحميل
        if (provider.status == OffersStatus.loading ||
            provider.status == OffersStatus.initial) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // حالة خطأ — اعرض زر إعادة المحاولة
        if (provider.status == OffersStatus.error) {
          return Padding(
            padding: const EdgeInsets.all(Dimens.largePadding),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.wifi_off_outlined, color: Colors.grey, size: 36),
                  const SizedBox(height: 8),
                  Text('تعذر تحميل العروض',
                      style: TextStyle(color: Colors.grey.shade600)),
                  TextButton(
                    onPressed: provider.fetchPublicOffers,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        // عرض كل العروض التي لديها خصم (بغض النظر عن status)
        final allOffers = provider.items
            .where((o) => o.discount > 0)
            .toList();

        // اذا لم توجد عروض اطلاقاً — اخفِ القسم بصمت
        if (allOffers.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
                itemCount: allOffers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) => _FlashOfferCard(
                  offer: allOffers[i],
                  now: _now,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.largePadding, Dimens.largePadding, Dimens.largePadding, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('عروض سريعة', style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text('الأسعار تنتهي قريباً!', style: typography.labelMedium.copyWith(color: colors.gray4)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('عرض الكل', style: typography.labelMedium.copyWith(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class _FlashOfferCard extends StatelessWidget {
  final Offer offer;
  final DateTime now;

  const _FlashOfferCard({required this.offer, required this.now});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    final endDt = offer.endDateTime;
    final Duration? remaining = endDt?.difference(now);
    final isExpired = remaining == null || remaining.isNegative;

    final imageUrl = offer.mainImage ?? offer.productImage;
    // نستخدم imageBaseUrl (بدون /api) لأن الصور على /uploads
    final fullImageUrl = imageUrl == null
        ? null
        : imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiConstants.imageBaseUrl}$imageUrl';

    final discountedPrice = offer.price * (1 - offer.discount / 100);

    return GestureDetector(
      onTap: () => appPush(context, ProductDetailsScreen(productId: offer.productId)),
      child: Container(
        width: 175,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج مع شارة الخصم
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _emptyImage(),
                        )
                      : _emptyImage(),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '-${offer.discount.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            // تفاصيل
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${discountedPrice.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        offer.price.toStringAsFixed(0),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // العداد التنازلي — نستخدم Builder لضمان الـ non-null بعد التحقق
                  Builder(builder: (_) {
                    final r = remaining;
                    if (!isExpired && r != null) return _CountdownChip(remaining: r);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'انتهى العرض',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 11),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyImage() => Container(
        height: 120,
        color: Colors.grey.shade100,
        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
      );
}

class _CountdownChip extends StatelessWidget {
  final Duration remaining;
  const _CountdownChip({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade600],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 13),
          Text(
            '$h:$m:$s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
