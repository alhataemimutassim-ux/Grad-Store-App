import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';

import '../../../../core/widgets/app_button.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
import 'package:grad_store_app/features/cart/presentation/state/checkout_provider.dart';
import 'package:grad_store_app/features/cart/presentation/pages/checkout_thankyou_page.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutProvider>().loadMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    final appColors = context.theme.appColors;
    return AppScaffold(
      appBar: GeneralAppBar(title: 'طرق الدفع'),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkout, child) {
          if (checkout.status == CheckoutStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (checkout.methods.isEmpty) {
            return const Center(child: Text('لا توجد طرق دفع متاحة'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildDynamicPaymentMethods(checkout, appColors),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: Dimens.largePadding,
          right: Dimens.largePadding,
          bottom: Dimens.padding,
        ),
        child: Consumer<CheckoutProvider>(
          builder: (context, checkout, child) {
            return AppButton(
              onPressed: checkout.status == CheckoutStatus.submitting
                  ? () {}
                  : () async {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final cartProv = context.read<CartProvider>();
                        final created = await checkout.submit(items: cartProv.items);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // إغلاق نافذة التحميل
                          
                          if (created != null) {
                            // نجح الدفع
                            try { await cartProv.clearCart(); } catch (_) {}
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => CheckoutThankYouPage(order: created)),
                            );
                          } else if (checkout.status == CheckoutStatus.error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(checkout.error), backgroundColor: Colors.red),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("خطأ أثناء إرسال الدفع: $e"), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              title: checkout.status == CheckoutStatus.submitting ? 'جاري التنفيذ...' : 'تأكيد الدفع',
              textStyle: appTypography.bodyLarge,
              borderRadius: Dimens.corners,
              margin: EdgeInsets.symmetric(vertical: Dimens.largePadding),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDynamicPaymentMethods(CheckoutProvider checkout, dynamic appColors) {
    return Column(
      children: checkout.methods.map((m) {
        final selected = checkout.selectedMethodId == m.id;
        final lower = m.name.toLowerCase();
        IconData icon;
        if (lower.contains('visa') || lower.contains('master') || lower.contains('card') || lower.contains('بطاقة')) {
          icon = Icons.credit_card;
        } else if (lower.contains('cash') || lower.contains('نقد') || lower.contains('cod')) {
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
                    color: selected ? appColors.primary.withOpacity(0.15) : appColors.gray,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: selected ? appColors.primary : appColors.gray4, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    m.name,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? appColors.primary : appColors.black,
                    ),
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: appColors.primary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
