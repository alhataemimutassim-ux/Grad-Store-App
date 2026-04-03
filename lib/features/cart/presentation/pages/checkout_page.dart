import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<CheckoutProvider>(context, listen: false);
    Future.microtask(() => prov.loadMethods());
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkout = Provider.of<CheckoutProvider>(context);
    final cartProv = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الدفع')),
  body: checkout.status == CheckoutStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('عناصر السلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProv.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cartProv.items[i];
                      final prod = cartProv.productCache[item.productId];
                      return ListTile(
                        leading: prod?.mainImage != null ? Image.network(prod!.mainImage!, width: 56, height: 56, fit: BoxFit.cover) : const SizedBox(width: 56, height: 56),
                        title: Text(prod?.name ?? 'منتج'),
                        subtitle: Text('الكمية: ${item.quantity}'),
                        trailing: Text('${((prod?.price ?? 0) * item.quantity).toStringAsFixed(2)} ج.م'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text('تفاصيل الشحن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
                const SizedBox(height: 8),
                TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'الهاتف')),
                const SizedBox(height: 12),
                const Text('طرق الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // Payment methods as selectable cards
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: checkout.methods.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (ctx2, idx) {
                      final m = checkout.methods[idx];
                      final selected = checkout.selectedMethodId == m.id;
                      IconData icon;
                      final lower = m.name.toLowerCase();
                      if (lower.contains('visa') || lower.contains('master')) {
                        icon = Icons.credit_card;
                      } else if (lower.contains('paypal')) {
                        icon = Icons.account_balance_wallet;
                      } else if (lower.contains('cash') || lower.contains('cod') || lower.contains('نقد')) {
                        icon = Icons.money;
                      } else {
                        icon = Icons.payment;
                      }

                      return GestureDetector(
                        onTap: () => checkout.setSelectedMethod(m.id),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.blue.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300, width: selected ? 2 : 1),
              boxShadow: selected
                ? [BoxShadow(color: const Color.fromRGBO(33, 150, 243, 0.08), blurRadius: 8, offset: const Offset(0, 4))]
                : [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(icon, size: 30, color: selected ? Colors.blue : Colors.grey[700]),
                            const SizedBox(height: 8),
                            Text(m.name, textAlign: TextAlign.center, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? Colors.blue : Colors.grey[800])),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<double>(
                  future: cartProv.computeTotal(),
                    builder: (ctx, snap) {
                    final totalText = snap.hasData ? snap.data!.toStringAsFixed(2) : '...';
                    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('المجموع الكلي: $totalText ج.م', style: const TextStyle(fontWeight: FontWeight.bold)), ElevatedButton(onPressed: () async {
                      checkout.address = _addressCtrl.text;
                      checkout.phone = _phoneCtrl.text;
                      // capture context before awaiting async work to safely use it later
                      final created = await checkout.submit(items: cartProv.items);
                      // debug logging to help trace why navigation might not occur
                      try {
                        // ignore: avoid_print
                        print('DEBUG: checkout.submit returned created=$created, status=${checkout.status}, error="${checkout.error}"');
                      } catch (_) {}
                      if (!mounted) return;
                      // safe: mounted was just checked
                      // capture navigator/messenger before awaiting to avoid using BuildContext across async gaps
                      // ignore: use_build_context_synchronously
                      final messenger = ScaffoldMessenger.of(context);
                      // ignore: use_build_context_synchronously
                      final navigator = Navigator.of(context);
                      if (created != null) {
                        navigator.pushReplacement(MaterialPageRoute(builder: (_) => CheckoutThankYouPage(order: created)));
                      } else if (checkout.status == CheckoutStatus.error) {
                        final err = checkout.error.toLowerCase();
                        // Detect unauthenticated error and prompt for login
                        if (err.contains('user not authenticated') || err.contains('not authenticated') || err.contains('غير مصرح') || err.contains('user not authenticated')) {
                          // direct navigation to LoginPage (simpler flow): open login and retry submit if successful
                          final res = await navigator.push(MaterialPageRoute(builder: (_) => const ResourceHandle.fromReadPipe()));
                          if (res == true) {
                            final created2 = await checkout.submit(items: cartProv.items);
                            if (!mounted) return;
                            if (created2 != null) {
                              navigator.pushReplacement(MaterialPageRoute(builder: (_) => CheckoutThankYouPage(order: created2)));
                            } else if (checkout.status == CheckoutStatus.error) {
                              messenger.showSnackBar(SnackBar(content: Text(checkout.error)));
                            }
                          }
                        } else {
                          messenger.showSnackBar(SnackBar(content: Text(checkout.error)));
                        }
                      }
                    }, child: const Text('أرسل الطلب'))]);
                  },
                )
              ]),
            ),
    );
  }
}
