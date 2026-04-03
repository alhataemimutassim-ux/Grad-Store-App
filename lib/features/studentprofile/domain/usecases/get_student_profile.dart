import '../repositories/student_profile_repository.dart';

class GetStudentProfile {
  final StudentProfileRepository repository;
  GetStudentProfile(this.repository);

  Future execute(int id) async {
    return await repository.getById(id);
  }
}
