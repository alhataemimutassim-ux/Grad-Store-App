class OrderItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double total;
  final String? productImage;

  // Seller info
  final int? sellerId;
  final String? sellerName;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    this.productImage,
    this.sellerId,
    this.sellerName,
  });
}
