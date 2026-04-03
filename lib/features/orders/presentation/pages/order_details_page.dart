import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// production: no debug-only imports
import '../../../products/presentation/state/products_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../orders/domain/entities/order.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #${order.id}'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'order-${order.id}',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                      child: Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طلب #${order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('التاريخ: ${_formatDate(order.orderDate)}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: _statusColor(order.statusName, context), borderRadius: BorderRadius.circular(20)),
                              child: Text(order.statusName, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            Text('${order.totalPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Shipping / Payment placeholders
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('طريقة الشحن', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('الشحن العادي'),
                ]),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('الدفع عند الاستلام'),
                ]),
              ),
            ]),

            const SizedBox(height: 18),

            const Text('العناصر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            // Items list
              ...order.items.map((it) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: it.productImage != null && it.productImage!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: FutureBuilder<List<dynamic>>(
                                future: Future.wait([
                                  Provider.of(context, listen: false).tokenManager.getAccessToken(),
                                  _fetchProductImageStrings(context, it.productId, it.productImage),
                                ]),
                                builder: (ctx, snap) {
                                  if (snap.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                  }
                                  final token = (snap.data != null && snap.data!.isNotEmpty) ? snap.data![0] as String? : null;
                                  final imgs = (snap.data != null && snap.data!.length > 1) ? (snap.data![1] as List<String>) : <String>[];

                                  // choose first available image from product images, otherwise fall back to order item image
                                  final selected = imgs.isNotEmpty ? imgs.first : (it.productImage ?? '');
                                  final candidates = selected.isNotEmpty ? _imageCandidates(selected) : <String>[];
                                  // production: do not print debug information here

                                  final url = candidates.isNotEmpty ? candidates.first : '';

                                  if (url.isEmpty) {
                                    // no candidate -> show placeholder avatar
                                    return Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary.withAlpha(30),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(child: Text(it.productName.isNotEmpty ? it.productName[0] : '?')),
                                    );
                                  }

                                  final networkImage = NetworkImage(url, headers: token == null ? null : {'Authorization': 'Bearer $token'});

                                  // Use Image with loadingBuilder & errorBuilder for graceful UX
                                  return GestureDetector(
                                    onTap: () {
                                      // open full-screen preview if desired
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                                        appBar: AppBar(title: Text(it.productName)),
                                        body: Center(child: Image(image: networkImage, fit: BoxFit.contain)),
                                      )));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Image(
                                          image: networkImage,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (ctx, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)));
                                          },
                                          errorBuilder: (ctx, error, stack) {
                                            return Container(
                                              color: Theme.of(context).colorScheme.secondary.withAlpha(30),
                                              alignment: Alignment.center,
                                              child: Text(it.productName.isNotEmpty ? it.productName[0] : '?'),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(30), child: Text(it.productName.isNotEmpty ? it.productName[0] : '?')),
                    title: Text(it.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بائع: ${it.sellerName ?? '-'}'),
                        // (production) do not show raw image path in subtitle
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${it.quantity} × ${it.unitPrice.toStringAsFixed(2)} ج.م'),
                        const SizedBox(height: 6),
                        Text('${it.total.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 12),

            // Totals breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _totalsRow('المجموع', '${order.totalPrice.toStringAsFixed(2)} ج.م'),
                  const SizedBox(height: 6),
                  _totalsRow('شحن', '0.00 ج.م'),
                  const Divider(),
                  _totalsRow('الإجمالي', '${order.totalPrice.toStringAsFixed(2)} ج.م', emphasize: true),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الطلب')));
                  },
                  child: const Text('نسخ رقم الطلب'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وظيفة تتبع الطلب (تجريبية)')));
                  },
                  child: const Text('تتبع الطلب'),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Color _statusColor(String status, BuildContext context) {
    final lc = status.toLowerCase();
    if (lc.contains('pending') || lc.contains('قيد')) return Colors.orange;
    if (lc.contains('shipped') || lc.contains('شحن')) return Colors.blue;
    if (lc.contains('delivered') || lc.contains('تم')) return Colors.green;
    if (lc.contains('cancel') || lc.contains('ملغى')) return Colors.red;
    return Theme.of(context).colorScheme.primary;
  }

  Widget _totalsRow(String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500)),
      ],
    );
  }

  // image candidate resolution: try several URL variants (host + path, uploads, storage, raw)

  List<String> _imageCandidates(String path) {
    final trimmed = path.trim();
    final List<String> candidates = [];
    if (trimmed.toLowerCase().startsWith('http')) {
      candidates.add(trimmed);
      return candidates;
    }

    // derive base host without the trailing /api if present
    var host = ApiConstants.baseUrl;
    if (host.endsWith('/api')) host = host.substring(0, host.length - 4);

    if (trimmed.startsWith('/')) {
      candidates.add('$host$trimmed');
      candidates.add('$host/uploads$trimmed');
      candidates.add('$host/storage$trimmed');
    } else {
      candidates.add('$host/$trimmed');
      candidates.add('$host/uploads/$trimmed');
      candidates.add('$host/storage/$trimmed');
    }

    // include raw trimmed (in case server returns protocol-relative URLs or other forms)
    candidates.add(trimmed);
    return candidates;
  }

  Future<List<String>> _fetchProductImageStrings(BuildContext context, int productId, String? fallback) async {
    try {
      final prov = Provider.of<ProductsProvider>(context, listen: false);
      final p = await prov.fetchById(productId);
      final main = p?.mainImage;
      if (main != null && main.isNotEmpty) return [main];
    } catch (e) {
      // ignore fetch errors and fall back
    }
    // fallback to provided order item image if any
    if (fallback != null && fallback.isNotEmpty) return [fallback];
    return <String>[];
  }

  // helper removed: no longer needed in production UI
}
