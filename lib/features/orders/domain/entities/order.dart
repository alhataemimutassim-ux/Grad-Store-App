import 'order_item.dart';

class Order {
  final int id;
  final DateTime orderDate;
  final String statusName;
  final double totalPrice;
  final List<OrderItem> items;

  Order({required this.id, required this.orderDate, required this.statusName, required this.totalPrice, required this.items});
}
