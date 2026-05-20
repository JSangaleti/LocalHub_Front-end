class PostModel {
  final int id;
  final int storeId;
  final String storeName;
  final int? categoryId;
  final String category;
  final String title;
  final String description;
  final String? imageUrl;
  final String? storeImageUrl;
  final int likes;
  final int comments;
  final bool isPromotion;
  final DateTime? createdAt;

  const PostModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    this.categoryId,
    required this.title,
    required this.description,
    this.category = 'Sem categoria',
    this.imageUrl,
    this.storeImageUrl,
    this.likes = 0,
    this.comments = 0,
    this.isPromotion = false,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: _parseInt(json['id']),
      storeId: _parseInt(json['storeId']),
      storeName: (json['storeName'] ?? 'Comercio').toString(),
      categoryId: _parseNullableInt(json['categoryId']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'Sem categoria').toString(),
      imageUrl: json['imageUrl']?.toString(),
      storeImageUrl: json['storeImageUrl']?.toString() ??
          json['store_image_url']?.toString(),
      likes: _parseIntDefault(json['likes']),
      comments: _parseIntDefault(json['comments']),
      isPromotion: _parseBool(json['isPromotion'] ?? json['is_promotion']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'title': title,
      'description': description,
      if (categoryId != null) 'categoryId': categoryId,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toCreateJson() => toJson()..remove('id');

  Map<String, dynamic> toUpdateJson() => toCreateJson();

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _parseIntDefault(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final s = value.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
