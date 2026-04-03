import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_profile_repository.dart';
import '../datasources/student_profile_remote_datasource.dart';
// model import not required here

class StudentProfileRepositoryImpl implements StudentProfileRepository {
  final StudentProfileRemoteDataSource remote;

  StudentProfileRepositoryImpl(this.remote);

  @override
  Future<StudentProfile?> getById(int id) async {
    final model = await remote.getById(id);
    if (model == null) return null;
    return StudentProfile(
      idUser: model.idUser,
      name: model.name,
      email: model.email,
      phone: model.phone,
      major: model.major,
      university: model.university,
    );
  }

  @override
  Future<void> update(UpdateStudentProfileRequest req) async {
    await remote.update(req.idUser, name: req.name, email: req.email, phone: req.phone, major: req.major, university: req.university);
  }
}
