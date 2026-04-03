import '../../domain/entities/seller.dart';

class SellerModel extends Seller {
  SellerModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.shopName,
    super.location,
    super.latitude,
    super.longitude,
    super.imagePath,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    // API uses PascalCase names (IdUser, Name, etc.) according to controller
    final id = json['IdUser'] ?? json['idUser'] ?? json['id'] ?? 0;
    return SellerModel(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      name: json['Name'] ?? json['name'] ?? '',
      email: json['Email'] ?? json['email'],
      phone: json['Phone'] ?? json['phone'],
      shopName: json['ShopName'] ?? json['shopName'] ?? json['shop_name'],
      location: json['Location'] ?? json['location'],
      latitude: (json['Latitude'] is num) ? (json['Latitude'] as num).toDouble() : (json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null),
      longitude: (json['Longitude'] is num) ? (json['Longitude'] as num).toDouble() : (json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null),
      imagePath: json['ImagePath'] ?? json['imagePath'] ?? json['image_path'],
    );
  }
}
