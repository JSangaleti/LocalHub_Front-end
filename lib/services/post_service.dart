import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  PostService({ApiService? apiService})
      : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<PostModel>> getPosts({String? search}) async {
    final queryParameters = <String, String>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _api.get(
      '/posts',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    final rawList = response is Map<String, dynamic>
        ? (response['data'] as List<dynamic>?)
        : response as List<dynamic>?;

    if (rawList == null) {
      throw ApiException('Resposta invalida ao carregar posts.');
    }

    return rawList.cast<Map<String, dynamic>>().map(PostModel.fromJson).toList();
  }
}