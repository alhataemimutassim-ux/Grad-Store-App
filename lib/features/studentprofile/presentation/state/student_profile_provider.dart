import 'package:flutter/material.dart';
import '../../../../core/utils/token_manager.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/usecases/get_student_profile.dart';
import '../../domain/usecases/update_student_profile.dart';
import '../../domain/repositories/student_profile_repository.dart';

enum StudentProfileStatus { initial, loading, loaded, error }

class StudentProfileProvider with ChangeNotifier {
  final GetStudentProfile getProfile;
  final UpdateStudentProfile updateProfile;
  final TokenManager tokenManager;

  StudentProfileProvider({required this.getProfile, required this.updateProfile, required this.tokenManager});

  StudentProfileStatus _status = StudentProfileStatus.initial;
  StudentProfileStatus get status => _status;

  StudentProfile? _profile;
  StudentProfile? get profile => _profile;

  String _error = '';
  String get error => _error;

  Future<void> fetchProfile() async {
    _status = StudentProfileStatus.loading;
    notifyListeners();
    try {
  final id = await tokenManager.getUserIdFromAccessToken() ?? 0;
      final p = await getProfile.execute(id);
      _profile = p as StudentProfile?;
      _status = StudentProfileStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = StudentProfileStatus.error;
    }
    notifyListeners();
  }

  Future<void> update({required String name, required String email, String? phone, String? major, String? university}) async {
    _status = StudentProfileStatus.loading;
    notifyListeners();
    try {
  final id = await tokenManager.getUserIdFromAccessToken() ?? 0;
      final req = UpdateStudentProfileRequest(idUser: id, name: name, email: email, phone: phone, major: major, university: university);
      await updateProfile.execute(req);
      await fetchProfile();
    } catch (e) {
      _error = e.toString();
      _status = StudentProfileStatus.error;
      notifyListeners();
      rethrow;
    }
  }
}
