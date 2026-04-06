abstract class UserProfile {
  final int idUser;
  final String name;
  final String email;
  final String phone;
  final int roleId;
  final String? profileImage;

  UserProfile({
    required this.idUser,
    required this.name,
    required this.email,
    required this.phone,
    required this.roleId,
    this.profileImage,
  });
}

class StudentProfileEntity extends UserProfile {
  final String? major;
  final String? university;

  StudentProfileEntity({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
    this.major,
    this.university,
  });
}

class SellerProfileEntity extends UserProfile {
  final String? shopName;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? instagram;
  final String? facebook;
  final String? whatsApp;

  SellerProfileEntity({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
    super.profileImage,
    this.shopName,
    this.location,
    this.latitude,
    this.longitude,
    this.instagram,
    this.facebook,
    this.whatsApp,
  });
}

class AdminProfileEntity extends UserProfile {
  final String? adminName;
  final String? projectName;
  final String? projectLogo;
  final String? projectDescription;
  final String? contactEmail;
  final String? location;
  final String? siteName;
  final double? latitude;
  final double? longitude;

  AdminProfileEntity({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
    this.adminName,
    this.projectName,
    this.projectLogo,
    this.projectDescription,
    this.contactEmail,
    this.location,
    this.siteName,
    this.latitude,
    this.longitude,
  });
}
