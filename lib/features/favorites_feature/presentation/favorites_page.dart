import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/app_icon_buttons.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/gen/assets.gen.dart';
import 'package:grad_store_app/features/wishlist/presentation/state/wishlist_provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    
    // Add post frame callback to load items if not already loaded (this is fallback, splash_screen might load it later or we can load it here)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<WishlistProvider>();
      if (p.items.isEmpty && p.status != WishlistStatus.loaded) {
         p.fetchMyWishlist();
      }
    });

    return AppScaffold(
      appBar: AppBar(title: const Text('المفضلات'), backgroundColor: colors.primary),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          if (provider.status == WishlistStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = provider.items;

          if (favorites.isEmpty) {
            return const Center(child: Text('لا توجد مفضلات بعد'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = favorites[index];
              return ListTile(
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.mainImage != null && item.mainImage!.isNotEmpty
                          ? Image.network(
                              item.mainImage!.startsWith('http') 
                                  ? item.mainImage! 
                                  : '${ApiConstants.baseUrl}${item.mainImage}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                            )
                          : Container(color: Colors.grey[300]),
                  ),
                ),
                title: Text(item.name ?? 'منتج غير معروف'),
                subtitle: Text('\$${item.price?.toStringAsFixed(2) ?? "0.00"}'),
                trailing: AppIconButton(
                  iconPath: Assets.icons.heart,
                  iconColor: colors.primary,
                  backgroundColor: colors.primary.withValues(alpha: 0.08),
                  onPressed: () {
                    provider.toggle(item.productId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
