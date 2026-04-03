import '../repositories/student_profile_repository.dart';

class UpdateStudentProfile {
  final StudentProfileRepository repository;
  UpdateStudentProfile(this.repository);

  Future<void> execute(UpdateStudentProfileRequest req) async {
    return await repository.update(req);
  }
}
