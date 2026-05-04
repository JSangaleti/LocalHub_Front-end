class PostModel {
  final String id;
  final String storeId;
  final String storeName;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;

  const PostModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(),
      storeId: json['storeId'].toString(),
      storeName: (json['storeName'] ?? 'Comercio').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'Sem categoria').toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}
