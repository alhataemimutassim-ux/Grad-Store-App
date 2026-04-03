import 'order_item_model.dart';

class OrderModel {
  final int idOrder;
  final String orderDate;
  final String statusName;
  final double totalPrice;
  final List<OrderItemModel> items;

  OrderModel({required this.idOrder, required this.orderDate, required this.statusName, required this.totalPrice, required this.items});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final itemsJson = json['items'];
    final List<OrderItemModel> itemsList = (itemsJson is List)
        ? itemsJson.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList()
        : <OrderItemModel>[];

    // support different server keys: some endpoints return `orderId` instead of `idOrder`
    final idCandidate = json['idOrder'] ?? json['orderId'];

    return OrderModel(
      idOrder: parseInt(idCandidate),
      orderDate: json['orderDate']?.toString() ?? DateTime.now().toIso8601String(),
      statusName: json['statusName']?.toString() ?? '',
      totalPrice: parseDouble(json['totalPrice']),
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'idOrder': idOrder,
        'orderDate': orderDate,
        'statusName': statusName,
        'totalPrice': totalPrice,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
