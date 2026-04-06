import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/features/categories/presentation/state/categories_provider.dart';


class CategoriesList extends StatelessWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;
    
    return Consumer<CategoriesProvider>(
      builder: (context, provider, child) {
        if (provider.status == CategoriesStatus.loading) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final categories = provider.items;
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (final context, final index) {
              final cat = categories[index];
              return Column(
                spacing: Dimens.padding,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26), // مربع شبه بيضاوي (Squircle)
                      color: context.theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: index == 0 ? Dimens.largePadding : Dimens.padding,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                          ? Image.network(
                              cat.imageUrl!.startsWith('http') 
                                ? cat.imageUrl! 
                                // إصلاح بسيط لمسار الصور
                                : 'https://posttest.somee.com${cat.imageUrl}',
                              fit: BoxFit.cover, // لتغطية الكارد بالكامل
                              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.category, size: 40, color: Colors.grey)),
                            )
                          : const Center(child: Icon(Icons.category, size: 40, color: Colors.grey)),
                    ),
                  ),
                  Text(cat.name),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
