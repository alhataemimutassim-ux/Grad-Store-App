import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'name': name,
      'description': description,
      'image': imageUrl,
    };
  }
}
