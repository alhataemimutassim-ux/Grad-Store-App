// import '../../domain/entities/sellerprofile.dart';

// class UserModel extends User {
//   UserModel({
//     required super.idUser,
//     required super.name,
//     required super.email,
//     required super.phone,
//     required super.shopname,
//     required super.location,
//     required super.latitude, 
//     required super.longitude,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       idUser: json['idUser'] ?? 0,
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       roleId: json['roleId'] ?? 1, 
//       shopname: '', location: '',
//        latitude: null,
//        longitude: null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'idUser': idUser,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'roleId': roleId,
//     };
//   }
// }