import '../../domain/entities/student_profile.dart';

class StudentProfileModel extends StudentProfile {
  StudentProfileModel({
    required super.idUser,
    super.name,
    super.email,
    super.phone,
    super.major,
    super.university,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      idUser: json['idUser'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['Name'],
      email: json['email'] ?? json['Email'],
      phone: json['phone'] ?? json['Phone'],
      major: json['major'] ?? json['Major'],
      university: json['university'] ?? json['University'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'name': name,
      'email': email,
      'phone': phone,
      'major': major,
      'university': university,
    };
  }
}
