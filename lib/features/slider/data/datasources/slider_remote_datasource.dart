import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/slider_image_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class SliderRemoteDataSource {
  Future<List<SliderImageModel>> getSliders();
}

class SliderRemoteDataSourceImpl implements SliderRemoteDataSource {
  final http.Client client;

  SliderRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SliderImageModel>> getSliders() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/slider');
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => SliderImageModel.fromJson(json)).toList();
      } else {
        throw ServerException('فشل في جلب السلايدرات من السيرفر.');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('حدث خطأ بالاتصال بالسيرفر: $e');
    }
  }
}
