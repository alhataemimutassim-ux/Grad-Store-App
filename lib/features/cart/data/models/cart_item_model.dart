class CartItemModel {
  final int idCartItem;
  final int productId;
  final int quantity;
  final int? userId;

  CartItemModel({required this.idCartItem, required this.productId, required this.quantity, this.userId});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      idCartItem: json['idCartItem'] ?? json['IdCartItem'] ?? 0,
      productId: json['productId'] ?? json['ProductId'] ?? 0,
      quantity: json['quantity'] ?? json['Quantity'] ?? 0,
      userId: json['userId'] ?? json['UserId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'IdCartItem': idCartItem,
        'ProductId': productId,
        'Quantity': quantity,
        'UserId': userId,
      };
}
