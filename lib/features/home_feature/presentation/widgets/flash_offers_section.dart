import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/features/offers/domain/entities/offer.dart';
import 'package:grad_store_app/features/offers/presentation/state/offers_provider.dart';
import 'package:grad_store_app/features/products/domain/entities/product.dart';
import 'package:grad_store_app/features/products/presentation/widgets/product_card.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';

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
    return AppScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const GeneralAppBar(title: 'عروض مؤقتة', showBackIcon: true),
      body: Consumer<OffersProvider>(
        builder: (context, provider, _) {
          // حالة التحميل
          if (provider.status == OffersStatus.loading ||
              provider.status == OffersStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          // حالة خطأ — اعرض زر إعادة المحاولة
          if (provider.status == OffersStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
            );
          }

          // عرض كل العروض التي لديها خصم
          final allOffers = provider.items.where((o) => o.discount > 0).toList();

          if (allOffers.isEmpty) {
            return const Center(child: Text("لا توجد عروض حالياً"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(Dimens.largePadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 210,
              crossAxisSpacing: Dimens.largePadding,
              mainAxisSpacing: Dimens.largePadding,
            ),
            itemCount: allOffers.length,
            itemBuilder: (ctx, i) {
              final offer = allOffers[i];
              final endDt = offer.endDateTime;
              final Duration? remaining = endDt?.difference(_now);
              final isExpired = remaining == null || remaining.isNegative;

              // Map Offer to Product for the unified card
              final productMapping = Product(
                id: offer.productId,
                name: offer.productName,
                price: offer.price,
                discount: offer.discount,
                qty: 1,
                isActive: offer.status,
                mainImage: offer.mainImage ?? offer.productImage,
                averageRating: offer.averageRating,
                reviewsCount: offer.reviewsCount,
                categoryId: 0,
                sellerId: 0,
              );

              return Stack(
                children: [
                  Positioned.fill(
                    child: ProductCard(product: productMapping),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Builder(builder: (_) {
                      if (!isExpired && remaining != null) return _CountdownChip(remaining: remaining);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Text(
                          'انتهى',
                          style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
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
