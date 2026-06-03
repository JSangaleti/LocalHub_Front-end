import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  final ApiService _api;

  PostService({ApiService? apiService}) : _api = apiService ?? ApiService();

  /// Buscar todos os posts
  /// [search] permite filtrar os posts pelo título ou conteúdo
  Future<List<PostModel>> getPosts({String? search}) async {
    final queryParameters = <String, String>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _api.get(
      '/posts',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    // Extrai a lista de posts da resposta
    final rawList = response is Map<String, dynamic>
        ? (response['data'] as List<dynamic>?)
        : response as List<dynamic>?;

    if (rawList == null) {
      throw ApiException('Resposta inválida ao carregar posts.');
    }

    return rawList.cast<Map<String, dynamic>>().map(PostModel.fromJson).toList();
  }

  /// Buscar um post específico pelo ID
  Future<PostModel> getPostById(int id) async {
    final response = await _api.get('/posts/$id');
    if (response == null) {
      throw ApiException('Post não encontrado.');
    }
    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  /// Criar um novo post
  Future<PostModel> createPost(PostModel post) async {
    final response = await _api.post('/posts', post.toJson());
    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  /// Atualizar um post existente
  Future<PostModel> updatePost(PostModel post) async {
    final response = await _api.put('/posts/${post.id}', post.toJson());
    return PostModel.fromJson(response as Map<String, dynamic>);
  }

  /// Deletar um post pelo ID
  Future<void> deletePost(int id) async {
    await _api.delete('/posts/$id');
  }
}