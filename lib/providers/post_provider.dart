import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/post_comment_model.dart';
import '../services/api_service.dart';
import '../services/post_interaction_service.dart';
import '../services/auth_service.dart';

class PostProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final PostInteractionService _interactions = PostInteractionService();

  List<PostModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll({
    int? userId,
    String? search,
    bool includeInactive = false,
  }) async {
    _setLoading(true);
    try {
      final queryParameters = <String, String>{};
      if (userId != null) queryParameters['userId'] = userId.toString();
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (includeInactive) queryParameters['includeInactive'] = 'true';

      final response = await _api.get(
        '/posts',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      final list = _extractList(response);
      _items = list.map(PostModel.fromJson).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  // Dentro de PostProvider

  Future<PostModel> fetchById(int id, {int? userId}) async {
    final post = await _api.get(
      '/posts/$id',
      queryParameters: userId == null ? null : {'userId': userId.toString()},
    );
    return PostModel.fromJson(post as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.delete('/posts/$id');
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<PostModel> create(Map<String, dynamic> body) async {
    body = {...body, 'actingUserId': AuthService().currentUser?.id};
    final response = await _api.post('/posts', body);
    final post = PostModel.fromJson((response as Map<String, dynamic>)['post']);
    _items.insert(0, post);
    notifyListeners();
    return post;
  }

  Future<PostModel> update(int id, Map<String, dynamic> body) async {
    body = {...body, 'actingUserId': AuthService().currentUser?.id};
    final response = await _api.put('/posts/$id', body);
    final post = PostModel.fromJson((response as Map<String, dynamic>)['post']);
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) _items[index] = post;
    notifyListeners();
    return post;
  }

  Future<List<PostModel>> fetchByStoreId(int storeId, {int? userId}) async {
    final response = await _api.get(
      '/posts',
      queryParameters: {
        'storeId': storeId.toString(),
        if (userId != null) 'userId': userId.toString(),
        if (userId != null) 'includeInactive': 'true',
      },
    );
    final list = response['data'] as List<dynamic>;
    return list.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<PostCommentModel>> fetchComments(int postId) async {
    return _interactions.getComments(postId);
  }

  Future<PostModel> addComment({
    required PostModel post,
    required int userId,
    required String content,
  }) async {
    final result = await _interactions.addComment(
      postId: post.id,
      userId: userId,
      content: content,
    );
    final updated = post.applyEngagement(result.engagement);
    _replaceInList(updated);
    return updated;
  }

  // Curtidas, comentários, CRUD permanecem iguais
  Future<PostModel> toggleLike(PostModel post, int userId) async {
    final engagement = post.likedByMe
        ? await _interactions.unlikePost(post.id, userId)
        : await _interactions.likePost(post.id, userId);
    final updated = post.applyEngagement(engagement);
    _replaceInList(updated);
    return updated;
  }

  Future<void> _replaceInList(PostModel updated) async {
    final index = _items.indexWhere((e) => e.id == updated.id);
    if (index >= 0) {
      _items[index] = updated;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List).cast<Map<String, dynamic>>();
    }
    if (response is List) return response.cast<Map<String, dynamic>>();
    return [];
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
