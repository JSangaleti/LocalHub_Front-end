import '../models/post_comment_model.dart';
import '../models/post_model.dart';
import 'api_service.dart';

class PostEngagement {
  final int likes;
  final int comments;
  final bool likedByMe;

  const PostEngagement({
    required this.likes,
    required this.comments,
    required this.likedByMe,
  });

  factory PostEngagement.fromJson(Map<String, dynamic> json) {
    return PostEngagement(
      likes: _parseInt(json['likes']),
      comments: _parseInt(json['comments']),
      likedByMe: json['likedByMe'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PostInteractionService {
  PostInteractionService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<PostEngagement> likePost(int postId, int userId) async {
    final response = await _api.post('/posts/$postId/likes', {'userId': userId});
    return PostEngagement.fromJson(response as Map<String, dynamic>);
  }

  Future<PostEngagement> unlikePost(int postId, int userId) async {
    final response =
        await _api.delete('/posts/$postId/likes?userId=$userId');
    return PostEngagement.fromJson(response as Map<String, dynamic>);
  }

  Future<List<PostCommentModel>> getComments(int postId) async {
    final response = await _api.get('/posts/$postId/comments');
    final list = _extractList(response);
    return list.map(PostCommentModel.fromJson).toList();
  }

  Future<({PostCommentModel comment, PostEngagement engagement})> addComment({
    required int postId,
    required int userId,
    required String content,
  }) async {
    final response = await _api.post('/posts/$postId/comments', {
      'userId': userId,
      'content': content,
    });
    final map = response as Map<String, dynamic>;
    return (
      comment: PostCommentModel.fromJson(
        map['comment'] as Map<String, dynamic>,
      ),
      engagement: PostEngagement.fromJson(map),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List).cast<Map<String, dynamic>>();
    }
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

extension PostEngagementApply on PostModel {
  PostModel applyEngagement(PostEngagement engagement) {
    return copyWith(
      likes: engagement.likes,
      comments: engagement.comments,
      likedByMe: engagement.likedByMe,
    );
  }
}
