import '../models/store_model.dart';
import 'api_service.dart';

class FavoriteStoreService {
  FavoriteStoreService({ApiService? apiService})
    : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<StoreModel>> getAll(int userId) async {
    final response = await _api.get('/users/$userId/favorite-stores');
    final stores = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return stores.map(StoreModel.fromJson).toList();
  }

  Future<void> add(int userId, int storeId) async {
    await _api.post('/users/$userId/favorite-stores/$storeId', const {});
  }

  Future<void> remove(int userId, int storeId) async {
    await _api.delete('/users/$userId/favorite-stores/$storeId');
  }
}
