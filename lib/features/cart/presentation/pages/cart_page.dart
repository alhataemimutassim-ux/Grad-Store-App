// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:grad_store_app/features/cart/presentation/state/cart_provider.dart';
 

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final provider = Provider.of<CartProvider>(context, listen: false);
      // Defer fetch to after the first frame to avoid calling notifyListeners
      // during the widget build phase (prevents 'setState called during build').
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchAll();
      });
      _inited = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات'), centerTitle: true),
      body: Consumer<CartProvider>(builder: (ctx, provider, _) {
        if (provider.status == CartStatus.loading) return const Center(child: CircularProgressIndicator());
        if (provider.status == CartStatus.error) return Center(child: Text(provider.error));
        if (provider.items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('السلة فارغة'), SizedBox(height:12), ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/'), child: Text('عرض المنتجات'))]));

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (ctx, i) {
                    final item = provider.items[i];
                    final prod = provider.productCache[item.productId];
                    return CartItemWidget(
                      item: item,
                      product: prod,
                      onIncrease: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await provider.changeQuantity(item.id, item.quantity + 1);
                          if (!mounted) return;
                        } catch (e) {
                          if (!mounted) return;
                          messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      onDecrease: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final newQty = (item.quantity - 1) < 1 ? 1 : item.quantity - 1;
                        try {
                          await provider.changeQuantity(item.id, newQty);
                          if (!mounted) return;
                        } catch (e) {
                          if (!mounted) return;
                          messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      onDelete: () {
                        showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('تأكيد'),
                            content: const Text('هل تريد حذف هذا العنصر؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لا')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نعم')),
                            ],
                          ),
                        ).then((ok) async {
                          if (ok == true) {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await provider.remove(item.id);
                              if (!mounted) return;
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              _buildSummary(provider),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummary(CartProvider provider) {
  // compute total by fetching product info synchronously is complex; compute approx by hitting product endpoints
    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/checkout'), child: const Text('المتابعة للدفع')),
          FutureBuilder<double>(
            future: provider.computeTotal(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Text('المجموع: ...');
              return Text('المجموع الكلي: ${snap.data!.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold));
            },
          ),
        ],
      ),
    );
  }

}
