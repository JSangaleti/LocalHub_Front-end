import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  PostService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<PostModel>> getPosts() async {
    final response = await _api.get('/posts');
    final rawList = (response as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return rawList.map(PostModel.fromJson).toList();
  }
}