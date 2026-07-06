import 'api_service.dart';

class SavedPostService {
  final ApiService _api;

  SavedPostService({ApiService? apiService}) : _api = apiService ?? ApiService();

  Future<Set<int>> getSavedIds(int userId) async {
    final response = await _api.get('/users/$userId/saved-posts');
    final list = (response as List<dynamic>);
    return list.map((e) => int.tryParse(e.toString())).whereType<int>().toSet();
  }

  Future<void> add(int userId, int postId) async {
    await _api.post('/users/$userId/saved-posts/$postId', const {});
  }

  Future<void> remove(int userId, int postId) async {
    await _api.delete('/users/$userId/saved-posts/$postId');
  }
}
