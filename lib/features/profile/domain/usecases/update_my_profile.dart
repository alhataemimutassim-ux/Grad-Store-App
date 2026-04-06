import 'dart:io';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateMyProfile {
  final ProfileRepository repository;

  UpdateMyProfile(this.repository);

  Future<void> execute(UserProfile profile, {File? imageFile}) async {
    return await repository.updateMyProfile(profile, imageFile: imageFile);
  }
}
