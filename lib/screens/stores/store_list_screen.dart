import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/admin_entity_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/entity_list_body.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await context.read<StoreProvider>().fetchAll();
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _openForm({int? id}) async {
    final saved = await Navigator.pushNamed(
      context,
      AppRoutes.storeForm,
      arguments: id,
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Lojas'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Consumer<StoreProvider>(
        builder: (context, provider, _) {
          return EntityListBody(
            isLoading: provider.isLoading,
            error: provider.error,
            isEmpty: provider.items.isEmpty,
            emptyMessage: 'Nenhuma loja cadastrada.',
            emptyIcon: Icons.storefront_outlined,
            onRetry: _load,
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final store = provider.items[index];
                  return AdminEntityCard(
                    title: store.name,
                    subtitle: '${store.category} • ID ${store.id}',
                    icon: Icons.store_outlined,
                    iconBackground: const Color(0xFFFFF0EB),
                    iconColor: const Color(0xFFFF6B35),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.storeDetail,
                      arguments: store.id,
                    ),
                    onEdit: () => _openForm(id: store.id),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
