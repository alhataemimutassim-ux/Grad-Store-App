// صفحة شكرًا بعد إتمام الطلب
import 'package:flutter/material.dart';
import '../../../orders/domain/entities/order.dart';
import 'package:grad_store_app/features/orders/presentation/pages/order_details_page.dart';

class CheckoutThankYouPage extends StatelessWidget {
  final Order? order;
  const CheckoutThankYouPage({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شكراً')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            const Text('تم استلام طلبك بنجاح', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('سنقوم بمعالجة الطلب وإبلاغك عند الشحن.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (order != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OrderDetailsPage(order: order!)),
                      ),
                      child: const Text('عرض تفاصيل الطلب'),
                    ),
                  ),
                ElevatedButton(
                  // زر يعود إلى الشاشة الرئيسية ويزيل باقي المسارات
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
                  child: const Text('العودة للرئيسية'),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}