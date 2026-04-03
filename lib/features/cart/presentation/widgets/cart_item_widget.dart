import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import '../../../products/data/models/product_model.dart';


class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final ProductModel? product;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const CartItemWidget({super.key, required this.item, this.product, required this.onIncrease, required this.onDecrease, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name = product?.name ?? 'منتج';
    final image = product?.mainImage ?? '';
    final price = product?.price ?? 0.0;
    final discount = product?.discount ?? 0.0;
    final total = (price - (price * discount / 100)) * item.quantity;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (image.isNotEmpty)
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(image, width: 88, height: 88, fit: BoxFit.cover))
              else
                Container(width: 88, height: 88, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('السعر: ${price.toStringAsFixed(2)} ج.م', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove), splashRadius: 18),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('${item.quantity}', style: const TextStyle(fontSize: 16))),
                              IconButton(onPressed: onIncrease, icon: const Icon(Icons.add), splashRadius: 18),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${total.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.red), label: const Text('حذف', style: TextStyle(color: Colors.red))),
                        ])
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
