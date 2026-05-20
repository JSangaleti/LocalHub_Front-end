import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  PostService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<PostModel>> getPosts() async {
    final response = await _api.get('/posts');
    final list = _extractList(response);
    return list.map(PostModel.fromJson).toList();
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
