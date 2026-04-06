import '../../domain/entities/user_profile.dart';

class StudentProfileModel extends StudentProfileEntity {
  StudentProfileModel({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
    super.major,
    super.university,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      idUser: json['idUser'] ?? json['IdUser'] ?? 0,
      name: json['name'] ?? json['Name'] ?? 'طالب',
      email: json['email'] ?? json['Email'] ?? '',
      phone: json['phone'] ?? json['Phone'] ?? '',
      roleId: 2, // بافتراض 2 للطلاب
      major: json['major'] ?? json['Major'],
      university: json['university'] ?? json['University'],
    );
  }
}

class SellerProfileModel extends SellerProfileEntity {
  SellerProfileModel({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
    super.profileImage,
    super.shopName,
    super.location,
    super.latitude,
    super.longitude,
    super.instagram,
    super.facebook,
    super.whatsApp,
  });

  factory SellerProfileModel.fromJson(Map<String, dynamic> json) {
    return SellerProfileModel(
      idUser: json['idUser'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      roleId: 1, // 1 for Seller
      profileImage: json['imagePath'],
      shopName: json['shopName'],
      location: json['location'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      instagram: json['instagram'],
      facebook: json['facebook'],
      whatsApp: json['whatsApp'],
    );
  }
}

class AdminProfileModel extends AdminProfileEntity {
  AdminProfileModel({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
    super.adminName,
    super.projectName,
    super.projectLogo,
    super.projectDescription,
    super.contactEmail,
    super.location,
    super.siteName,
    super.latitude,
    super.longitude,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      idUser: json['idUser'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      roleId: 3, // 3 for Admin
      adminName: json['adminName'],
      projectName: json['projectName'],
      projectLogo: json['projectLogo'],
      projectDescription: json['projectDescription'],
      contactEmail: json['contactEmail'],
      location: json['location'],
      siteName: json['siteName'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
