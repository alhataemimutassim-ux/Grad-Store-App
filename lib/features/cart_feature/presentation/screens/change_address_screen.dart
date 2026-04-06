import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';
import 'package:grad_store_app/core/widgets/general_app_bar.dart';

import '../../../../core/widgets/app_button.dart';
import 'package:grad_store_app/features/cart/presentation/state/checkout_provider.dart';

class ChangeAddressScreen extends StatefulWidget {
  const ChangeAddressScreen({super.key});

  @override
  State<ChangeAddressScreen> createState() => _ChangeAddressScreenState();
}

class _ChangeAddressScreenState extends State<ChangeAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<CheckoutProvider>();
      _addressCtrl.text = prov.address == 'العنوان الافتراضي - قيد التطوير' ? '' : prov.address;
      _phoneCtrl.text = prov.phone == '0500000000' ? '' : prov.phone;
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTypography = context.theme.appTypography;
    final appColors = context.theme.appColors;

    return AppScaffold(
      appBar: GeneralAppBar(title: 'إضافة عنوان جديد'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimens.largePadding),
              Text('معلومات التوصيل', style: appTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: Dimens.largePadding),
              TextFormField(
                controller: _addressCtrl,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال العنوان' : null,
                decoration: InputDecoration(
                  labelText: 'العنوان التفصيلي',
                  hintText: 'مثال: شارع القادسية, مبنى 20',
                  prefixIcon: Icon(Icons.location_on_outlined, color: appColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimens.corners)),
                ),
              ),
              const SizedBox(height: Dimens.largePadding),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال رقم الهاتف' : null,
                decoration: InputDecoration(
                  labelText: 'رقم للتواصل',
                  hintText: 'مثال: 0500000000',
                  prefixIcon: Icon(Icons.phone_outlined, color: appColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimens.corners)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: Dimens.largePadding,
          right: Dimens.largePadding,
          bottom: Dimens.padding,
        ),
        child: AppButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final prov = context.read<CheckoutProvider>();
              prov.address = _addressCtrl.text.trim();
              prov.phone = _phoneCtrl.text.trim();
              Navigator.pop(context);
            }
          },
          title: 'حفظ ومتابعة',
          textStyle: appTypography.bodyLarge,
          borderRadius: Dimens.corners,
          margin: const EdgeInsets.symmetric(vertical: Dimens.largePadding),
        ),
      ),
    );
  }
}
