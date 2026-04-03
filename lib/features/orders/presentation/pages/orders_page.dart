import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../orders/domain/entities/order.dart';
import '../state/orders_provider.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    final prov = Provider.of<OrdersProvider>(context, listen: false);
    Future.microtask(() => prov.fetchMyOrders());
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<OrdersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Builder(builder: (ctx) {
          if (prov.status == OrdersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.status == OrdersStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(prov.error),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => prov.fetchMyOrders(), child: const Text('حاول مرة أخرى')),
                ],
              ),
            );
          }

          if (prov.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.inbox, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('لا توجد طلبات بعد', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: prov.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final Order o = prov.orders[i];
              // preview first item name (if any)
              final preview = o.items.isNotEmpty ? o.items.first.productName : '';
              final firstImage = o.items.isNotEmpty ? o.items.first.productImage : null;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderDetailsPage(order: o)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Avatar / thumbnail with hero
                        Hero(
                          tag: 'order-${o.id}',
                          child: firstImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(firstImage, width: 56, height: 56, fit: BoxFit.cover),
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(child: Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Main info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text('طلب #${o.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _statusColor(o.statusName, context),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(o.statusName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(preview, style: const TextStyle(color: Colors.black54), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(_formatDate(o.orderDate), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Price and chevron
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${o.totalPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 8),
                            const Icon(Icons.chevron_left, color: Colors.black26),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Color _statusColor(String status, BuildContext context) {
    final lc = status.toLowerCase();
    if (lc.contains('pending') || lc.contains('قيد')) return Colors.orange;
    if (lc.contains('shipped') || lc.contains('شحن')) return Colors.blue;
    if (lc.contains('delivered') || lc.contains('تم')) return Colors.green;
    if (lc.contains('cancel') || lc.contains('ملغى')) return Colors.red;
    return Theme.of(context).colorScheme.primary;
  }

  String _formatDate(DateTime dt) {
    // Simple formatting: dd/mm/yyyy
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
