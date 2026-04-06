import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../orders/domain/entities/order.dart';
import '../state/orders_provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Order currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    final typography = context.theme.appTypography;

    // تحديث الطلب محلياً في حالة تغييره (مثل الإلغاء)
    final prov = Provider.of<OrdersProvider>(context);
    final idx = prov.orders.indexWhere((o) => o.id == currentOrder.id);
    if (idx != -1) {
      currentOrder = prov.orders[idx];
    }

    final isCancelable = currentOrder.statusName.trim() == 'قيد الانتظار' || currentOrder.statusName.trim() == 'قيد المعالجة' || currentOrder.statusName.trim() == 'قيد الموافقة';

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تفاصيل الطلب',
          style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: appColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة ملخص الطلب
            _buildOrderSummaryCard(context, appColors, typography),
            const SizedBox(height: 24),

            // تفاصيل الدفع والشحن
            _buildInfoRow(appColors, typography),
            const SizedBox(height: 24),

            // عناصر الطلب
            Text(
              'المنتجات (${currentOrder.items.length})',
              style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...currentOrder.items.map((item) => _buildOrderItem(context, item, appColors, typography)),

            const SizedBox(height: 24),

            // ملخص الفاتورة
            _buildReceiptCard(context, appColors, typography),

            const SizedBox(height: 32),

            // أزرار الإجراءات
            if (isCancelable) ...[
              AppButton(
                title: 'إلغاء الطلب',
                color: appColors.error,
                onPressed: () => _showCancelConfirmation(context, prov),
              ),
              const SizedBox(height: 12),
            ],
            AppButton(
              title: 'تتبع الطلب',
              color: appColors.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('سيتم توفير ميزة التتبع قريباً'),
                    backgroundColor: appColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, dynamic appColors, dynamic typography) {
    final statusColor = _getStatusColor(currentOrder.statusName.trim(), appColors);

    return Container(
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب رقم #${currentOrder.id}',
                  style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(currentOrder.orderDate),
                  style: typography.labelMedium.copyWith(color: appColors.gray4),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentOrder.statusName,
                    style: typography.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(dynamic appColors, dynamic typography) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            appColors,
            typography,
            icon: Icons.local_shipping_outlined,
            title: 'الشحن',
            subtitle: 'توصيل عادي',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoItem(
            appColors,
            typography,
            icon: Icons.payment_outlined,
            title: 'الدفع',
            subtitle: 'الدفع عند الاستلام',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(dynamic appColors, dynamic typography, {required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.gray2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: appColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(title, style: typography.labelMedium.copyWith(color: appColors.gray4)),
          const SizedBox(height: 4),
          Text(subtitle, style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, dynamic item, dynamic appColors, dynamic typography) {
    final imageUrl = item.productImage != null && item.productImage!.isNotEmpty
        ? (item.productImage!.startsWith('http')
            ? item.productImage!
            : '${ApiConstants.imageBaseUrl}${item.productImage}')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: appColors.gray2,
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(Icons.image_not_supported, color: appColors.gray4)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'متجر: ${item.sellerName ?? "غير معروف"}',
                  style: typography.labelMedium.copyWith(color: appColors.gray4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity} x ${item.unitPrice.toStringAsFixed(2)} ر.س',
                      style: typography.labelMedium.copyWith(color: appColors.gray4),
                    ),
                    Text(
                      '${item.total.toStringAsFixed(2)} ر.س',
                      style: typography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: appColors.primary,
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
  }

  Widget _buildReceiptCard(BuildContext context, dynamic appColors, dynamic typography) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: appColors.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الدفع',
            style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildReceiptRow('المجموع الفرعي', '${currentOrder.totalPrice.toStringAsFixed(2)} ر.س', typography, appColors),
          const SizedBox(height: 12),
          _buildReceiptRow('تكلفة الشحن', '0.00 ر.س', typography, appColors),
          const SizedBox(height: 12),
          Divider(color: appColors.gray2),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${currentOrder.totalPrice.toStringAsFixed(2)} ر.س',
                style: typography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value, dynamic typography, dynamic appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: typography.bodyMedium.copyWith(color: appColors.gray4)),
        Text(value, style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context, OrdersProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              prov.cancelOrder(currentOrder.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء الطلب بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('نعم، إلغاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')} / ${dt.month.toString().padLeft(2, '0')} / ${dt.year}';
  }

  Color _getStatusColor(String status, dynamic appColors) {
    if (status == 'تم التسليم' || status == 'مكتمل') return appColors.successLight;
    if (status == 'ملغي') return appColors.error;
    if (status == 'قيد الانتظار' || status == 'قيد المعالجة' || status == 'قيد الموافقة') return Colors.orange;
    return appColors.primary;
  }
}
