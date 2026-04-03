class PaymentMethodModel {
  final int id;
  final String name;

  PaymentMethodModel({required this.id, required this.name});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? json['idMethod'] ?? 0,
      name: json['name'] ?? json['methodName'] ?? '',
    );
  }
}
