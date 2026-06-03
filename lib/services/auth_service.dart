import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  AuthService._internal(this._api);

  static AuthService? _instance;

  /// Instância compartilhada (mantém sessão após login entre telas).
  factory AuthService({ApiService? apiService}) {
    if (apiService != null) {
      return AuthService._internal(apiService);
    }
    _instance ??= AuthService._internal(ApiService());
    return _instance!;
  }

  final ApiService _api;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  void clearSession() {
    _currentUser = null;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final user = UserModel.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
    _currentUser = user;
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    final response = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'userType': accountType,
    });

    return UserModel.fromJson(
      (response as Map<String, dynamic>)['user'] as Map<String, dynamic>,
    );
  }
}
