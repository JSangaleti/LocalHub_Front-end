import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<NotificationModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      final items = await _service.getAll(user.id);
      if (mounted) setState(() => _items = items);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    await _service.markAllAsRead(user.id);
    await _load();
  }

  Future<void> _markOne(NotificationModel item) async {
    final user = AuthService().currentUser;
    if (user == null || item.isRead) return;
    await _service.markAsRead(item.id, user.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Notificações',
        actions: [
          if (_items.any((item) => !item.isRead))
            TextButton(onPressed: _markAll, child: const Text('Ler todas')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Nenhuma notificação',
              subtitle: 'As interações com seus posts aparecerão aqui.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    color: item.isRead
                        ? AppColors.surface
                        : AppColors.primaryLight,
                    child: ListTile(
                      onTap: () => _markOne(item),
                      leading: Icon(
                        item.interactionType == 'like'
                            ? Icons.favorite_rounded
                            : Icons.chat_bubble_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(item.message),
                      subtitle: item.createdAt == null
                          ? null
                          : Text(_formatDate(item.createdAt!)),
                      trailing: item.isRead
                          ? null
                          : const Icon(Icons.circle, size: 10),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
