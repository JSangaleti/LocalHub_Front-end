class NotificationModel {
  final int id;
  final int actorUserId;
  final String actorName;
  final int postId;
  final String postTitle;
  final String interactionType;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.actorUserId,
    required this.actorName,
    required this.postId,
    required this.postTitle,
    required this.interactionType,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _parseInt(json['id']),
      actorUserId: _parseInt(json['actorUserId']),
      actorName: (json['actorName'] ?? 'Usuário').toString(),
      postId: _parseInt(json['postId']),
      postTitle: (json['postTitle'] ?? 'Post').toString(),
      interactionType: (json['interactionType'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
