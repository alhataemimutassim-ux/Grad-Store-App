// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import '../state/cart_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<CartProvider>(context, listen: false).fetchAll();
      });
      _inited = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return Scaffold(
      backgroundColor: appColors.secondaryShade1,
      appBar: AppBar(
        title: Text(
          'سلة المشتريات',
          style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: appColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: appColors.black),
      ),
      body: Consumer<CartProvider>(builder: (ctx, provider, _) {
        if (provider.status == CartStatus.loading) {
          return Center(
            child: CircularProgressIndicator(color: appColors.primary),
          );
        }
        if (provider.status == CartStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: appColors.error),
                const SizedBox(height: 12),
                Text(provider.error, style: typography.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchAll(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        if (provider.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: appColors.gray2),
                const SizedBox(height: 16),
                Text('سلتك فارغة!', style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('ابدأ بإضافة منتجات لسلتك', style: typography.bodyMedium.copyWith(color: appColors.gray4)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('تصفح المنتجات'),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor: appColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: provider.items.length,
                itemBuilder: (ctx, i) {
                  final item = provider.items[i];
                  final prod = provider.productCache[item.productId];
                  final name = prod?.name ?? 'جار التحميل...';
                  final rawImg = prod?.mainImage ?? '';
                  final imageUrl = rawImg.isNotEmpty
                      ? (rawImg.startsWith('http') ? rawImg : '${ApiConstants.imageBaseUrl}$rawImg')
                      : null;
                  final price = prod?.price ?? 0.0;
                  final discount = prod?.discount ?? 0.0;
                  final unitPrice = price - (price * discount / 100);
                  final total = unitPrice * item.quantity;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: appColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // صورة المنتج
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _imagePlaceholder(appColors),
                                  )
                                : _imagePlaceholder(appColors),
                          ),
                          const SizedBox(width: 12),
                          // بيانات المنتج
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (discount > 0) ...[
                                  Text(
                                    '${price.toStringAsFixed(2)} ر.س',
                                    style: typography.labelMedium.copyWith(
                                      color: appColors.gray4,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    '${unitPrice.toStringAsFixed(2)} ر.س',
                                    style: typography.bodyMedium.copyWith(
                                      color: appColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    '${unitPrice.toStringAsFixed(2)} ر.س',
                                    style: typography.bodyMedium.copyWith(
                                      color: appColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // أزرار الكمية
                                    Container(
                                      decoration: BoxDecoration(
                                        color: appColors.secondaryShade1,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _qtyBtn(
                                            icon: Icons.remove,
                                            color: appColors.gray4,
                                            onTap: () async {
                                              final newQty = (item.quantity - 1) < 1 ? 1 : item.quantity - 1;
                                              try {
                                                await provider.changeQuantity(item.id, newQty);
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              '${item.quantity}',
                                              style: typography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          _qtyBtn(
                                            icon: Icons.add,
                                            color: appColors.primary,
                                            onTap: () async {
                                              try {
                                                await provider.changeQuantity(item.id, item.quantity + 1);
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(e.toString())),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    // الإجمالي للمنتج
                                    Text(
                                      '${total.toStringAsFixed(2)} ر.س',
                                      style: typography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: appColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // زر الحذف
                          IconButton(
                            onPressed: () => _confirmDelete(context, provider, item.id),
                            icon: Icon(Icons.delete_outline, color: appColors.error, size: 22),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // ملخص السلة وزر الدفع
            _buildBottomBar(context, provider, appColors, typography),
          ],
        );
      }),
    );
  }

  Widget _qtyBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _imagePlaceholder(dynamic appColors) {
    return Container(
      width: 80,
      height: 80,
      color: appColors.gray,
      child: Icon(Icons.image_not_supported, color: appColors.gray4),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider provider, dynamic appColors, dynamic typography) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: appColors.white,
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // إجمالي السلة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('إجمالي السلة', style: typography.bodyMedium.copyWith(color: appColors.gray4)),
              FutureBuilder<double>(
                future: provider.computeTotal(),
                builder: (ctx, snap) {
                  final total = snap.data?.toStringAsFixed(2) ?? '...';
                  return Text(
                    '$total ر.س',
                    style: typography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // زر المتابعة للدفع
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.payment_rounded),
              label: const Text('المتابعة للدفع'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                foregroundColor: appColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CartProvider provider, int itemId) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: const Text('هل تريد حذف هذا المنتج من السلة؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('تراجع')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((ok) async {
      if (ok == true) {
        try {
          await provider.remove(itemId);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    });
  }
}
