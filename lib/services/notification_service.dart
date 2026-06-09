import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  NotificationService({ApiService? apiService})
    : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<NotificationModel>> getAll(int userId) async {
    final response = await _api.get(
      '/notifications',
      queryParameters: {'userId': userId.toString()},
    );
    final data = (response as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
  }

  Future<void> markAsRead(int id, int userId) async {
    await _api.put('/notifications/$id/read', {'userId': userId});
  }

  Future<void> markAllAsRead(int userId) async {
    await _api.put('/notifications/read-all', {'userId': userId});
  }
}
