import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_divider.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:grad_store_app/features/orders/presentation/state/orders_provider.dart';

enum OrderType { active, completed, canceled }

class OrdersListWidget extends StatelessWidget {
  const OrdersListWidget({super.key, required this.orderType});

  final OrderType orderType;

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        if (provider.status == OrdersStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredOrders = provider.orders.where((o) {
          if (orderType == OrderType.active) return o.statusName != 'Delivered' && o.statusName != 'Canceled';
          if (orderType == OrderType.completed) return o.statusName == 'Delivered';
          if (orderType == OrderType.canceled) return o.statusName == 'Canceled';
          return false;
        }).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text(
              'لا توجد طلبات هنا',
              style: context.theme.appTypography.bodyLarge.copyWith(color: appColors.gray),
            ),
          );
        }

        return ListView.separated(
          itemCount: filteredOrders.length,
          itemBuilder: (final context, final index) {
            final order = filteredOrders[index];
            final firstItem = order.items.isNotEmpty ? order.items.first : null;
            
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.largePadding,
                vertical: Dimens.veryLargePadding,
              ),
              child: Row(
                spacing: Dimens.largePadding,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 95,
                    width: 95,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.corners),
                      child: firstItem?.productImage != null && firstItem!.productImage!.isNotEmpty
                          ? Image.network(
                              firstItem.productImage!.startsWith('http') 
                                  ? firstItem.productImage! 
                                  : '${ApiConstants.baseUrl}${firstItem.productImage}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                            )
                          : Container(color: Colors.grey[300]),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: Text(
                            'طلب رقم #${order.id}',
                            style: context.theme.appTypography.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              spacing: Dimens.largePadding,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الكمية : ${order.items.fold(0, (sum, i) => sum + i.quantity)} قطع',
                                  style: context.theme.appTypography.labelMedium
                                      .copyWith(color: appColors.gray4),
                                ),
                                Text(
                                  '\$ ${order.totalPrice.toStringAsFixed(2)}',
                                  style: context.theme.appTypography.bodyLarge,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 110,
                              height: 32,
                              child: AppButton(
                                title:
                                    orderType == OrderType.active
                                        ? 'تتبع الطلب'
                                        : orderType == OrderType.completed
                                        ? 'تم التوصيل'
                                        : 'اطلب مرة اخرئ',
                                color:
                                    orderType == OrderType.active
                                        ? appColors.primary
                                        : orderType == OrderType.completed
                                        ? appColors.successLight
                                        : appColors.error,
                                margin: EdgeInsets.zero,
                                padding: WidgetStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.symmetric(horizontal: Dimens.padding),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (final context, final index) {
            return const AppDivider(height: 0);
          },
        );
      },
    );
  }
}
