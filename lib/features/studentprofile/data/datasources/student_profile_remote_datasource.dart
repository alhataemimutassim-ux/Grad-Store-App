import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/token_manager.dart';
import '../models/student_profile_model.dart';

abstract class StudentProfileRemoteDataSource {
  Future<StudentProfileModel?> getById(int id);
  Future<void> update(int id, {required String name, required String email, String? phone, String? major, String? university});
}

class StudentProfileRemoteDataSourceImpl implements StudentProfileRemoteDataSource {
  final http.Client client;
  final TokenManager? tokenManager;

  StudentProfileRemoteDataSourceImpl(this.client, {this.tokenManager});

  @override
  Future<StudentProfileModel?> getById(int id) async {
    // controller expects id in path but uses token's id; we still pass id
    final uri = Uri.parse('${ApiConstants.baseUrl}/studentprofiles/full/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await client.get(uri, headers: headers);
    if (res.statusCode == 404) return null;
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception(res.body);
    }
    final Map<String, dynamic> json = jsonDecode(res.body);
    return StudentProfileModel.fromJson(json);
  }

  @override
  Future<void> update(int id, {required String name, required String email, String? phone, String? major, String? university}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/studentprofiles/full/$id');
    final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final body = jsonEncode({
      'name': name,
      'email': email,
      'phone': phone,
      'major': major,
      'university': university,
    });
    final res = await client.put(uri, headers: headers, body: body);
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception(res.body);
    }
  }
}
