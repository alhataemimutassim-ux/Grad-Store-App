import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_my_profile.dart';
import '../../domain/usecases/update_my_profile.dart';
import '../../../../core/utils/app_error_handler.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final GetMyProfile getMyProfile;
  final UpdateMyProfile updateMyProfileUseCase;

  ProfileProvider({
    required this.getMyProfile,
    required this.updateMyProfileUseCase,
  });

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  ProfileStatus _status = ProfileStatus.initial;
  ProfileStatus get status => _status;

  String _error = '';
  String get error => _error;

  Future<void> fetchProfile() async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      _profile = await getMyProfile.execute();
      _status = ProfileStatus.loaded;
    } catch (e) {
      _error = AppErrorHandler.getMessage(e);
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }

  Future<bool> updateProfile(UserProfile updatedProfile, {File? imageFile}) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      await updateMyProfileUseCase.execute(updatedProfile, imageFile: imageFile);
      
      // Update local state without re-fetching
      _profile = updatedProfile;
      // If we uploaded an image, ideally we'd re-fetch, but let's re-fetch just in case
      await fetchProfile();
      return true;
    } catch (e) {
      _error = AppErrorHandler.getMessage(e);
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }
}
