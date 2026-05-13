class PostModel {
  final String id;
  final String storeId;
  final String storeName;
  final String title;
  final String description;
  final String category;
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
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    this.storeImageUrl,
    this.likes = 0,
    this.comments = 0,
    this.isPromotion = false,
    this.createdAt,
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
      storeImageUrl: json['storeImageUrl']?.toString() ??
          json['store_image_url']?.toString(),
      likes: _parseInt(json['likes']),
      comments: _parseInt(json['comments']),
      isPromotion: _parseBool(json['isPromotion'] ?? json['is_promotion']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
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
