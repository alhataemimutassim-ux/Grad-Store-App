// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import '../state/checkout_provider.dart';
import '../state/cart_provider.dart';
import 'checkout_thankyou_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CheckoutProvider>(context, listen: false).loadMethods());
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.theme.appColors;
    final typography = context.theme.appTypography;
    final checkout = Provider.of<CheckoutProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: appColors.secondaryShade1,
      appBar: AppBar(
        title: Text(
          'إتمام الطلب',
          style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: appColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: appColors.black),
      ),
      body: checkout.status == CheckoutStatus.loading
          ? Center(child: CircularProgressIndicator(color: appColors.primary))
          : checkout.status == CheckoutStatus.submitting
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: appColors.primary),
                      const SizedBox(height: 16),
                      Text('جاري إرسال الطلب...', style: typography.bodyMedium),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- قائمة المنتجات ---
                        _sectionTitle('منتجات طلبك (${cartProv.items.length})', appColors, typography),
                        const SizedBox(height: 12),
                        ...cartProv.items.map((item) {
                          final prod = cartProv.productCache[item.productId];
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
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: appColors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageUrl != null
                                      ? Image.network(imageUrl,
                                          width: 60, height: 60, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _imgPlaceholder(60, appColors))
                                      : _imgPlaceholder(60, appColors),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('الكمية: ${item.quantity}',
                                          style: typography.labelMedium.copyWith(color: appColors.gray4)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${total.toStringAsFixed(2)} ر.س',
                                  style: typography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: appColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // --- بيانات الشحن ---
                        _sectionTitle('بيانات الشحن', appColors, typography),
                        const SizedBox(height: 12),
                        _buildCard(
                          appColors,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _addressCtrl,
                                label: 'العنوان',
                                hint: 'أدخل عنوان التسليم',
                                icon: Icons.location_on_outlined,
                                appColors: appColors,
                                typography: typography,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneCtrl,
                                label: 'رقم الهاتف',
                                hint: 'أدخل رقم هاتفك',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                appColors: appColors,
                                typography: typography,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'رقم الهاتف مطلوب' : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- طرق الدفع ---
                        _sectionTitle('طريقة الدفع', appColors, typography),
                        const SizedBox(height: 12),
                        if (checkout.methods.isEmpty)
                          _buildCard(
                            appColors,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('لا توجد طرق دفع متاحة',
                                    style: typography.bodyMedium.copyWith(color: appColors.gray4)),
                              ),
                            ),
                          )
                        else
                          ...checkout.methods.map((m) {
                            final selected = checkout.selectedMethodId == m.id;
                            final lower = m.name.toLowerCase();
                            IconData icon;
                            if (lower.contains('visa') || lower.contains('master') || lower.contains('card')) {
                              icon = Icons.credit_card;
                            } else if (lower.contains('cash') || lower.contains('نقد')) {
                              icon = Icons.money;
                            } else if (lower.contains('wallet') || lower.contains('محفظة')) {
                              icon = Icons.account_balance_wallet;
                            } else {
                              icon = Icons.payment;
                            }

                            return GestureDetector(
                              onTap: () => checkout.setSelectedMethod(m.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selected ? appColors.primaryShade1 : appColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected ? appColors.primary : appColors.gray2,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: selected ? appColors.primary.withValues(alpha: 0.15) : appColors.gray,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon,
                                          color: selected ? appColors.primary : appColors.gray4, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(m.name,
                                          style: typography.bodyMedium.copyWith(
                                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                            color: selected ? appColors.primary : appColors.black,
                                          )),
                                    ),
                                    if (selected)
                                      Icon(Icons.check_circle, color: appColors.primary),
                                  ],
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 20),

                        // --- ملخص الفاتورة ---
                        _sectionTitle('ملخص الطلب', appColors, typography),
                        const SizedBox(height: 12),
                        _buildCard(
                          appColors,
                          child: FutureBuilder<double>(
                            future: cartProv.computeTotal(),
                            builder: (ctx, snap) {
                              final total = snap.data ?? 0.0;
                              return Column(
                                children: [
                                  _receiptRow('المجموع الفرعي', '${total.toStringAsFixed(2)} ر.س', appColors, typography),
                                  const SizedBox(height: 10),
                                  _receiptRow('تكلفة الشحن', 'مجاني', appColors, typography, valueColor: appColors.success),
                                  Divider(color: appColors.gray2, height: 24),
                                  _receiptRow(
                                    'الإجمالي',
                                    '${total.toStringAsFixed(2)} ر.س',
                                    appColors,
                                    typography,
                                    bold: true,
                                    valueColor: appColors.primary,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- زر إرسال الطلب ---
                        if (checkout.status == CheckoutStatus.error)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: appColors.errorLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: appColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(checkout.error,
                                      style: typography.bodyMedium.copyWith(color: appColors.error)),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('تأكيد الطلب وإرساله'),
                            onPressed: () => _submit(context, checkout, cartProv),
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> _submit(BuildContext context, CheckoutProvider checkout, CartProvider cartProv) async {
    if (!_formKey.currentState!.validate()) return;
    checkout.address = _addressCtrl.text.trim();
    checkout.phone = _phoneCtrl.text.trim();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final created = await checkout.submit(items: cartProv.items);

    if (!mounted) return;

    if (created != null) {
      // مسح السلة بعد نجاح الطلب
      try {
        await cartProv.clearCart();
      } catch (_) {}
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => CheckoutThankYouPage(order: created)),
      );
    } else if (checkout.status == CheckoutStatus.error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(checkout.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _sectionTitle(String title, dynamic appColors, dynamic typography) {
    return Text(
      title,
      style: typography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: appColors.black),
    );
  }

  Widget _buildCard(dynamic appColors, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required dynamic appColors,
    required dynamic typography,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: appColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appColors.gray2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appColors.gray2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: appColors.primary, width: 2),
        ),
        filled: true,
        fillColor: appColors.secondaryShade1,
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value,
    dynamic appColors,
    dynamic typography, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: typography.bodyMedium.copyWith(
              color: bold ? appColors.black : appColors.gray4,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            )),
        Text(value,
            style: typography.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? appColors.black,
            )),
      ],
    );
  }

  Widget _imgPlaceholder(double size, dynamic appColors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: appColors.gray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.image_not_supported, color: appColors.gray4, size: size * 0.4),
    );
  }
}
