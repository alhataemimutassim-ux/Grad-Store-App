import '../entities/student_profile.dart';

abstract class StudentProfileRepository {
  Future<StudentProfile?> getById(int id);
  Future<void> update(UpdateStudentProfileRequest request);
}

class UpdateStudentProfileRequest {
  final int idUser;
  final String name;
  final String email;
  final String? phone;
  final String? major;
  final String? university;

  UpdateStudentProfileRequest({required this.idUser, required this.name, required this.email, this.phone, this.major, this.university});
}
