import 'package:flutter/foundation.dart';

import '../models/store_model.dart';
import '../services/api_service.dart';

class StoreProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<StoreModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<StoreModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _setLoading(true);
    try {
      final response = await _api.get('/stores');
      final list = (response as List<dynamic>).cast<Map<String, dynamic>>();
      _items = list.map(StoreModel.fromJson).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<StoreModel> fetchById(int id) async {
    final response = await _api.get('/stores/$id');
    return StoreModel.fromJson(response as Map<String, dynamic>);
  }

  Future<StoreModel> create(Map<String, dynamic> body) async {
    final response = await _api.post('/stores', body);
    final store = StoreModel.fromJson(
      (response as Map<String, dynamic>)['store'] as Map<String, dynamic>,
    );
    _items = [..._items, store];
    notifyListeners();
    return store;
  }

  Future<StoreModel> update(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/stores/$id', body);
    final store = StoreModel.fromJson(
      (response as Map<String, dynamic>)['store'] as Map<String, dynamic>,
    );
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = store;
      notifyListeners();
    }
    return store;
  }

  Future<void> delete(int id) async {
    await _api.delete('/stores/$id');
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
