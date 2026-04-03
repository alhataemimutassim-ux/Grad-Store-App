import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/app_icon_buttons.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/gen/assets.gen.dart';
import '../../cart_feature/data/models/product_model.dart';
import 'favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    return AppScaffold(
      appBar: AppBar(title: Text('المفضلات'), backgroundColor: colors.primary),
      body: BlocBuilder<FavoritesCubit, List<ProductModel>>(
        builder: (context, favorites) {
          if (favorites.isEmpty) {
            return Center(child: Text('لا توجد مفضلات بعد'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = favorites[index];
              return ListTile(
                leading: SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(item.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                title: Text(item.name),
                subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                trailing: AppIconButton(
                  iconPath: Assets.icons.heart,
                  iconColor: colors.primary,
                  backgroundColor: colors.primary.withValues(alpha: 0.08),
                  onPressed: () {
                    context.read<FavoritesCubit>().toggle(item);
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
