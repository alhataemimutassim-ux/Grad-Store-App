import 'package:flutter/material.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import '../../../orders/domain/entities/order.dart';
import 'package:grad_store_app/features/orders/presentation/pages/order_details_page.dart';

class CheckoutThankYouPage extends StatelessWidget {
  final Order? order;
  const CheckoutThankYouPage({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    final typography = context.theme.appTypography;

    return Scaffold(
      backgroundColor: appColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // أيقونة النجاح
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: appColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: appColors.success,
                  size: 80,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'تم استلام طلبك! 🎉',
                style: typography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'شكراً لك على طلبك. سنقوم بمعالجة الطلب وإبلاغك فور الشحن.',
                style: typography.bodyMedium.copyWith(color: appColors.gray4),
                textAlign: TextAlign.center,
              ),
              if (order != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColors.secondaryShade1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: appColors.gray2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoItem('رقم الطلب', '#${order!.id}', appColors, typography),
                      Container(height: 40, width: 1, color: appColors.gray2),
                      _infoItem(
                        'الحالة',
                        order!.statusName.isNotEmpty ? order!.statusName : 'قيد الانتظار',
                        appColors,
                        typography,
                        highlight: true,
                      ),
                      Container(height: 40, width: 1, color: appColors.gray2),
                      _infoItem(
                        'الإجمالي',
                        '${order!.totalPrice.toStringAsFixed(2)} ر.س',
                        appColors,
                        typography,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // الأزرار
              if (order != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('عرض تفاصيل الطلب'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderDetailsPage(order: order!)),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: appColors.primary,
                      side: BorderSide(color: appColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('العودة للرئيسية'),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (r) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    foregroundColor: appColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value, dynamic appColors, dynamic typography, {bool highlight = false}) {
    return Column(
      children: [
        Text(label, style: typography.labelMedium.copyWith(color: appColors.gray4)),
        const SizedBox(height: 4),
        Text(
          value,
          style: typography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? appColors.primary : appColors.black,
          ),
        ),
      ],
    );
  }
}