import '../models/store_model.dart';
import 'auth_service.dart';
import 'store_service.dart';

/// Verifica se o usuário logado possui uma loja cadastrada.
class MyStoreService {
  MyStoreService({StoreService? storeService})
      : _stores = storeService ?? StoreService();

  final StoreService _stores;

  Future<StoreModel?> findStoreForCurrentUser() async {
    final user = AuthService().currentUser;
    if (user == null) return null;
    return _stores.resolveForProfile(ownerUserId: user.id);
  }
}
