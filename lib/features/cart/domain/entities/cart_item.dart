class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final int? userId;

  CartItem({required this.id, required this.productId, required this.quantity, this.userId});
}
