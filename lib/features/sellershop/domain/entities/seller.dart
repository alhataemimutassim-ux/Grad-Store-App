class Seller {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? shopName;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? imagePath;

  Seller({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.shopName,
    this.location,
    this.latitude,
    this.longitude,
    this.imagePath,
  });
}
