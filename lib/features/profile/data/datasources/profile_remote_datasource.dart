import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_profile.dart';
import '../models/profile_models.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getMyProfile();
  Future<void> updateMyProfile(UserProfile profile, {File? imageFile});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final TokenManager tokenManager;

  ProfileRemoteDataSourceImpl({required this.client, required this.tokenManager});

  Future<Map<String, String>> _headers() async {
    final token = await tokenManager.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserProfile> getMyProfile() async {
    final roleId = await tokenManager.getRoleIdFromAccessToken();
    final userId = await tokenManager.getUserIdFromAccessToken();

    if (userId == null || roleId == null) {
      throw ServerException('تعذر جلب بيانات المستخدم من الجلسة.');
    }

    try {
      if (roleId == 1) { // Seller
        final url = Uri.parse('${ApiConstants.baseUrl}/sellerprofiles/full/$userId');
        final response = await client.get(url, headers: await _headers());
        if (response.statusCode == 200) {
          return SellerProfileModel.fromJson(json.decode(response.body));
        } else if (response.statusCode == 404) {
          return SellerProfileModel(idUser: userId, name: 'بائع', email: '', phone: '', roleId: 1);
        } else {
          throw ServerException('فشل في جلب بيانات البائع (${response.statusCode})');
        }
      } else if (roleId == 3) { // Admin
        final url = Uri.parse('${ApiConstants.baseUrl}/adminprofiles/full/byid');
        final response = await client.get(url, headers: await _headers());
        if (response.statusCode == 200) {
          return AdminProfileModel.fromJson(json.decode(response.body));
        } else if (response.statusCode == 404) {
          return AdminProfileModel(idUser: userId, name: 'مدير النظام', email: '', phone: '', roleId: 3);
        } else {
          throw ServerException('فشل في جلب بيانات الإدارة (${response.statusCode})');
        }
      } else { // Student (fallback role 2)
        final url = Uri.parse('${ApiConstants.baseUrl}/studentprofiles/full/$userId');
        final response = await client.get(url, headers: await _headers());
        if (response.statusCode == 200) {
          return StudentProfileModel.fromJson(json.decode(response.body));
        } else if (response.statusCode == 404) {
          return StudentProfileModel(idUser: userId, name: 'طالب', email: '', phone: '', roleId: 2);
        } else {
          throw ServerException('فشل في جلب بيانات الطالب (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('خطأ في الاتصال بالشبكة: $e');
    }
  }

  @override
  Future<void> updateMyProfile(UserProfile profile, {File? imageFile}) async {
    final roleId = profile.roleId;
    final userId = profile.idUser;
    final token = await tokenManager.getAccessToken();

    try {
      if (roleId == 1) { // Seller
        final p = profile as SellerProfileEntity;
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${ApiConstants.baseUrl}/sellerprofiles/full'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        // Add fields
        request.fields['Name'] = p.name;
        request.fields['Email'] = p.email;
        request.fields['Phone'] = p.phone;
        if (p.shopName != null) request.fields['ShopName'] = p.shopName!;
        if (p.location != null) request.fields['Location'] = p.location!;
        if (p.latitude != null) request.fields['Latitude'] = p.latitude.toString();
        if (p.longitude != null) request.fields['Longitude'] = p.longitude.toString();
        if (p.instagram != null) request.fields['Instagram'] = p.instagram!;
        if (p.facebook != null) request.fields['Facebook'] = p.facebook!;
        if (p.whatsApp != null) request.fields['WhatsApp'] = p.whatsApp!;

        if (imageFile != null) {
          request.files.add(await http.MultipartFile.fromPath('ImageFile', imageFile.path));
        }

        final response = await request.send();
        if (response.statusCode != 200) {
          throw ServerException('فشل في تحديث بيانات المتجر.');
        }

      } else if (roleId == 3) { // Admin
        final p = profile as AdminProfileEntity;
        final url = Uri.parse('${ApiConstants.baseUrl}/adminprofiles/full/edit');
        final response = await client.put(
          url,
          headers: await _headers(),
          body: json.encode({
            'Name': p.name,
            'Email': p.email,
            'Phone': p.phone,
            'AdminName': p.adminName,
            'ProjectName': p.projectName,
            'ProjectDescription': p.projectDescription,
            'ContactEmail': p.contactEmail,
            'Location': p.location,
            'SiteName': p.siteName,
            'Latitude': p.latitude,
            'Longitude': p.longitude,
          }),
        );
        if (response.statusCode != 200) {
          throw ServerException('فشل في تحديث بيانات الإدارة.');
        }

      } else { // Student
        final p = profile as StudentProfileEntity;
        final url = Uri.parse('${ApiConstants.baseUrl}/studentprofiles/full/$userId');
        final response = await client.put(
          url,
          headers: await _headers(),
          body: json.encode({
            'Major': p.major,
            'University': p.university,
          }),
        );
        if (response.statusCode != 200) {
          throw ServerException('فشل في تحديث بيانات الطالب (${response.statusCode})');
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('خطأ في الاتصال بالشبكة: $e');
    }
  }
}
