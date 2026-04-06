import 'dart:io';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getMyProfile() async {
    return await remoteDataSource.getMyProfile();
  }

  @override
  Future<void> updateMyProfile(UserProfile profile, {File? imageFile}) async {
    return await remoteDataSource.updateMyProfile(profile, imageFile: imageFile);
  }
}
