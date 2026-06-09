import '../models/store_model.dart';
import 'api_service.dart';

class StoreService {
  StoreService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<StoreModel>> getAll() async {
    final response = await _api.get('/stores');
    final rawList = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return rawList.map(StoreModel.fromJson).toList();
  }

  Future<List<StoreModel>> getByOwner(int ownerUserId) async {
    final response = await _api.get(
      '/stores',
      queryParameters: {'ownerUserId': ownerUserId.toString()},
    );
    final rawList = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return rawList
        .map(StoreModel.fromJson)
        .where((store) => store.ownerUserId == ownerUserId)
        .toList();
  }

  Future<StoreModel> getById(int id) async {
    final response = await _api.get('/stores/$id');
    return StoreModel.fromJson(response as Map<String, dynamic>);
  }

  /// Resolve a loja para exibir no perfil: por id, dono ou primeira da lista.
  Future<StoreModel?> resolveForProfile({
    int? storeId,
    int? ownerUserId,
  }) async {
    if (storeId != null) {
      return getById(storeId);
    }
    final all = ownerUserId != null
        ? await getByOwner(ownerUserId)
        : await getAll();
    if (ownerUserId != null) {
      try {
        return all.firstWhere((s) => s.ownerUserId == ownerUserId);
      } catch (_) {
        return null;
      }
    }
    if (all.isNotEmpty) {
      return all.first;
    }
    return null;
  }
}
