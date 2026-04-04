import 'package:flutter/material.dart';
import 'package:grad_store_app/core/widgets/animated_fade_in.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../../wishlist/presentation/state/wishlist_provider.dart';
import 'package:grad_store_app/core/widgets/rounded_card.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails d) => setState(() => _scale = 0.97);
  void _onTapUp(TapUpDetails d) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (d) {
        _onTapUp(d);
        widget.onTap?.call();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedFadeIn(
          child: RoundedCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: product.mainImage != null
                            ? Image.network(product.mainImage!, fit: BoxFit.cover)
                            : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 48)),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
                          final inWishlist = wp.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final added = await wp.toggle(product.id);
                                messenger.showSnackBar(SnackBar(content: Text(added ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة')));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text('فشل العملية: ${e.toString()}')));
                              }
                            },
                            child: CircleAvatar(
                              radius: 18,
                                backgroundColor: Theme.of(context).colorScheme.surface.withAlpha((0.9 * 255).round()),
                                child: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? Colors.red : Colors.grey),
                            ),
                          );
                        }),
                      ),
                      // discount badge (if any) - placed topLeft
                      if (product.discount > 0)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                            // discount قادم من السرفر كنسبة مئوية (10 = 10٪)
                            child: Text('-${product.discount.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                    ],
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // product name
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        // rating row (if available)
                        Builder(builder: (ctx) {
                          // try to read optional rating fields if present on model
                          double? avg;
                          int? reviewsCount;
                          try {
                            final p = product as dynamic;
                            avg = (p.averageRating == null) ? null : (p.averageRating as double?);
                            reviewsCount = (p.reviewsCount == null) ? null : (p.reviewsCount as int?);
                          } catch (_) {
                            avg = null;
                            reviewsCount = null;
                          }

                          if (avg != null && avg > 0) {
                            // Use Wrap so rating items can wrap to the next line on narrow widths
                            return Wrap(
                              spacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _StarRating(rating: avg, size: 14),
                                // ensure numeric text doesn't overflow the available space
                                SizedBox(
                                  width: 36,
                                  child: Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                                if (reviewsCount != null)
                                  SizedBox(
                                    width: 48,
                                    child: Text('($reviewsCount)', style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                            );
                          }

                          return const Text('لا تقييم', style: TextStyle(fontSize: 12, color: Colors.grey));
                        }),
                        const SizedBox(height: 8),
                        // prices
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          // السعر بعد الخصم: discount من السرفر كنسبة مئوية
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              '${(product.discount > 0 ? (product.price * (1 - product.discount / 100)) : product.price).toStringAsFixed(2)} ر.س',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // old price
                          if (product.discount > 0)
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                '${product.price.toStringAsFixed(2)} ر.س',
                                style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const Spacer(),
                          // small add-to-cart or qty indicator
                          if (product.qty <= 0)
                            SizedBox(
                              width: 80,
                              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: const Text('غير متوفر', style: TextStyle(fontSize: 12))),
                            )
                          else
                            SizedBox(
                              width: 80,
                              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: const Text('متوفر', style: TextStyle(fontSize: 12))),
                            )
                        ])
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Small widget to render star rating with half-star support.
class _StarRating extends StatelessWidget {
  final double rating; // expected 0..5
  final double size;

  const _StarRating({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = List.generate(5, (i) {
      final idx = i + 1;
      IconData icon;
      if (rating >= idx) {
        icon = Icons.star;
      } else if (rating >= idx - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
  return Icon(icon, size: size, color: Colors.amber[600]);
    });
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
