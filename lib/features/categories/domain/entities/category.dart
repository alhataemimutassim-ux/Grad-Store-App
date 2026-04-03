class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });
}
