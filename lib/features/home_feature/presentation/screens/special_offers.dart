import 'package:flutter/material.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';

import '../../../../core/theme/dimens.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/offers/presentation/state/offers_provider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';

class SpecialOffers extends StatelessWidget {
  const SpecialOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: GeneralAppBar(title: 'عروض خاصة'),
      body: Consumer<OffersProvider>(
        builder: (context, provider, child) {
          if (provider.status == OffersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final banners = provider.items;
          if (banners.isEmpty) {
            return const Center(child: Text("لا توجد عروض حالياً"));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Dimens.largePadding),
            itemCount: banners.length,
            itemBuilder: (final context, final index) {
              final bannerUrl = banners[index].mainImage;
              final fullUrl = bannerUrl != null && bannerUrl.isNotEmpty 
                ? (bannerUrl.startsWith('http') ? bannerUrl : '${ApiConstants.baseUrl}$bannerUrl')
                : null;
              
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(Dimens.largePadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimens.largePadding),
                  child: fullUrl != null 
                    ? Image.network(fullUrl, errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.grey[300]))
                    : Container(height: 150, color: Colors.grey[300]),
                ),
              );
            },
            separatorBuilder: (final context, final index) {
              return const SizedBox(height: Dimens.largePadding);
            },
          );
        },
      ),
    );
  }
}
