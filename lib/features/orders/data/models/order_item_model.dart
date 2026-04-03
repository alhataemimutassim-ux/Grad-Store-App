class OrderItemModel {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double total;
  final String? productImage;
  final int? sellerId;
  final String? sellerName;

  OrderItemModel({required this.productId, required this.productName, required this.unitPrice, required this.quantity, required this.total, this.productImage, this.sellerId, this.sellerName});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
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

    return OrderItemModel(
      productId: parseInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      unitPrice: parseDouble(json['unitPrice']),
      quantity: parseInt(json['quantity']),
      total: parseDouble(json['total']),
      productImage: json['productImage']?.toString(),
      sellerId: json['sellerId'] == null ? null : parseInt(json['sellerId']),
      sellerName: json['sellerName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'total': total,
        'productImage': productImage,
        'sellerId': sellerId,
        'sellerName': sellerName,
      };
}
