import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CategoryModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _setLoading(true);
    try {
      final response = await _api.get('/categories');
      final list = (response as List<dynamic>).cast<Map<String, dynamic>>();
      _items = list.map(CategoryModel.fromJson).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CategoryModel> fetchById(int id) async {
    final response = await _api.get('/categories/$id');
    return CategoryModel.fromJson(response as Map<String, dynamic>);
  }

  Future<CategoryModel> create(String name) async {
    final response = await _api.post('/categories', {'name': name});
    final category = CategoryModel.fromJson(
      (response as Map<String, dynamic>)['category'] as Map<String, dynamic>,
    );
    _items = [..._items, category];
    notifyListeners();
    return category;
  }

  Future<CategoryModel> update(int id, String name) async {
    final response = await _api.put('/categories/$id', {'name': name});
    final category = CategoryModel.fromJson(
      (response as Map<String, dynamic>)['category'] as Map<String, dynamic>,
    );
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = category;
      notifyListeners();
    }
    return category;
  }

  Future<void> delete(int id) async {
    await _api.delete('/categories/$id');
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
