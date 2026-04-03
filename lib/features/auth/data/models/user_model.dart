import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.idUser,
    required super.name,
    required super.email,
    required super.phone,
    required super.roleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['idUser'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      roleId: json['roleId'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'name': name,
      'email': email,
      'phone': phone,
      'roleId': roleId,
    };
  }
}