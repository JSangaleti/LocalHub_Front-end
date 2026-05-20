import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<UserModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _setLoading(true);
    try {
      final response = await _api.get('/users');
      final list = (response as List<dynamic>).cast<Map<String, dynamic>>();
      _items = list.map(UserModel.fromJson).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel> fetchById(int id) async {
    final response = await _api.get('/users/$id');
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<UserModel> create({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    final response = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
    });
    final user = UserModel.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
    _items = [user, ..._items];
    notifyListeners();
    return user;
  }

  Future<UserModel> update(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/users/$id', body);
    final user = UserModel.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = user;
      notifyListeners();
    }
    return user;
  }

  Future<void> delete(int id) async {
    await _api.delete('/users/$id');
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
