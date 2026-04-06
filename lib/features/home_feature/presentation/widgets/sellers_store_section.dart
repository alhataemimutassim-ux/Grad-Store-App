import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/app_navigator.dart';
import 'package:grad_store_app/features/sellershop/domain/entities/seller.dart';
import 'package:grad_store_app/features/sellershop/presentation/state/sellers_provider.dart';
import 'package:grad_store_app/features/sellershop/presentation/pages/seller_details_page.dart';

/// قسم متاجر البائعين — بطاقات أفقية أنيقة
class SellersStoreSection extends StatefulWidget {
  const SellersStoreSection({super.key});

  @override
  State<SellersStoreSection> createState() => _SellersSectionState();
}

class _SellersSectionState extends State<SellersStoreSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SellersProvider>();
      if (p.status == SellersStatus.initial) p.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellersProvider>(
      builder: (context, provider, _) {
        if (provider.status == SellersStatus.loading ||
            provider.status == SellersStatus.initial) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, provider),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.largePadding, vertical: 4),
                itemCount: provider.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) => _SellerCard(seller: provider.items[i]),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, SellersProvider provider) {
    final colors = context.theme.appColors;
    final typography = context.theme.appTypography;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimens.largePadding, 4, Dimens.largePadding, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('متاجر البائعين',
                  style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text('${provider.items.length} متجر متاح',
                  style: typography.labelMedium.copyWith(color: colors.gray4)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('عرض الكل',
                style: typography.labelMedium.copyWith(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final Seller seller;
  const _SellerCard({required this.seller});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;

    final imgUrl = seller.imagePath == null
        ? null
        : seller.imagePath!.startsWith('http')
            ? seller.imagePath!
            : '${ApiConstants.imageBaseUrl}${seller.imagePath}';

    // توليد لون فريد من الـ id للخلفية الـ avatar
    final hue = (seller.id * 47) % 360;
    final avatarColor = HSLColor.fromAHSL(1.0, hue.toDouble(), 0.5, 0.55).toColor();

    return GestureDetector(
      onTap: () => appPush(context, SellerDetailsPage(sellerId: seller.id)),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة المتجر أو Avatar بالاختصار
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    avatarColor.withValues(alpha: 0.9),
                    avatarColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: imgUrl != null
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(seller, avatarColor),
                      )
                    : _avatarFallback(seller, avatarColor),
              ),
            ),
            const SizedBox(height: 10),
            // اسم المتجر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                seller.shopName ?? seller.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 4),
            // الموقع أو دور "بائع"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                seller.location ?? 'بائع معتمد',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.gray4, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            // زر عرض المتجر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'عرض المتجر',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback(Seller seller, Color color) {
    final initial = (seller.shopName ?? seller.name).isNotEmpty
        ? (seller.shopName ?? seller.name)[0].toUpperCase()
        : 'S';
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
    );
  }
}
