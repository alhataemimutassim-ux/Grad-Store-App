import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetMyProfile {
  final ProfileRepository repository;

  GetMyProfile(this.repository);

  Future<UserProfile> execute() async {
    return await repository.getMyProfile();
  }
}
