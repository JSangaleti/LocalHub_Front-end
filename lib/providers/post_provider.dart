import 'package:flutter/foundation.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';

class PostProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<PostModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _setLoading(true);
    try {
      final response = await _api.get('/posts');
      final list = _extractList(response);
      _items = list.map(PostModel.fromJson).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<PostModel> fetchById(int id) async {
    final response = await _api.get('/posts/$id');
    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  Future<PostModel> create(Map<String, dynamic> body) async {
    final response = await _api.post('/posts', body);
    final post = PostModel.fromJson(
      (response as Map<String, dynamic>)['post'] as Map<String, dynamic>,
    );
    _items = [post, ..._items];
    notifyListeners();
    return post;
  }

  Future<PostModel> update(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/posts/$id', body);
    final post = PostModel.fromJson(
      (response as Map<String, dynamic>)['post'] as Map<String, dynamic>,
    );
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = post;
      notifyListeners();
    }
    return post;
  }

  Future<void> delete(int id) async {
    await _api.delete('/posts/$id');
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
