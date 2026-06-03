import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/store_model.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/entity_list_body.dart';

class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  StoreModel? _store;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = ModalRoute.of(context)?.settings.arguments;
    if (id is! int) return;

    setState(() => _isLoading = true);
    try {
      final store = await context.read<StoreProvider>().fetchById(id);
      if (mounted) setState(() => _store = store);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (_store == null) return;
    final confirmed = await confirmDelete(
      context,
      message: 'Deseja remover a loja "${_store!.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<StoreProvider>().delete(_store!.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Loja removida.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Detalhes da loja',
        actions: [
          if (_store != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await Navigator.pushNamed(
                  context,
                  AppRoutes.storeForm,
                  arguments: _store!.id,
                );
                if (saved == true) _load();
              },
            ),
        ],
      ),
      body: DetailBody(
        isLoading: _isLoading,
        isEmpty: _store == null,
        emptyMessage: 'Loja não encontrada.',
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DetailHeroCard(
                      title: _store!.name,
                      subtitle: _store!.category,
                      icon: Icons.storefront_rounded,
                      badges: [
                        DetailBadge(label: 'ID ${_store!.id}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          DetailInfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Dono (userId)',
                            value: '${_store!.ownerUserId ?? "-"}',
                          ),
                          DetailInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Endereço',
                            value: _store!.address ?? 'Não informado',
                          ),
                          DetailInfoRow(
                            icon: Icons.schedule_rounded,
                            label: 'Horário',
                            value: _store!.openingHours ?? 'Não informado',
                          ),
                          DetailInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Contato',
                            value: _store!.contact ?? 'Não informado',
                          ),
                          if (_store!.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            DetailInfoRow(
                              icon: Icons.description_outlined,
                              label: 'Descrição',
                              value: _store!.description!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StickyBottomActions(
              children: [
                CustomButton(
                  text: 'Excluir loja',
                  variant: CustomButtonVariant.destructive,
                  icon: Icons.delete_outline,
                  onPressed: _delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
