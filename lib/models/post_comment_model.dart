class PostCommentModel {
  final int id;
  final int postId;
  final int userId;
  final String userName;
  final String content;
  final DateTime? createdAt;

  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: _parseInt(json['id']),
      postId: _parseInt(json['postId']),
      userId: _parseInt(json['userId']),
      userName: (json['userName'] ?? 'Usuário').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
