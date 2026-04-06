import '../../domain/entities/slider_image.dart';

class SliderImageModel extends SliderImage {
  SliderImageModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.displayOrder,
    required super.isActive,
  });

  factory SliderImageModel.fromJson(Map<String, dynamic> json) {
    return SliderImageModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }
}
