import 'dart:io';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getMyProfile();
  
  /// يتم التحديث حسب نوع بيانات الكلاس المُرسل (Student, Seller, Admin)
  /// والصورة المُرفقة إذا وجدت (طبعاً للطالب قد لا يكون هناك صورة لكن الواجهة ستتعامل معها)
  Future<void> updateMyProfile(UserProfile profile, {File? imageFile});
}
