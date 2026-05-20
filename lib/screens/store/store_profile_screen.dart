import 'package:flutter/material.dart';

import '../../models/store_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../widgets/store_card.dart';

/// Argumentos opcionais ao abrir [StoreProfileScreen].
class StoreProfileRouteArgs {
  final int? ownerUserId;
  final int? storeId;

  const StoreProfileRouteArgs({
    this.ownerUserId,
    this.storeId,
  });
}

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final StoreService _storeService = StoreService();
  bool _isLoading = true;
  String? _errorMessage;
  StoreModel? _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadStore();
    });
  }

  StoreProfileRouteArgs? _readArgs() {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is StoreProfileRouteArgs) return raw;
    return null;
  }

  Future<void> _loadStore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final args = _readArgs();
    final auth = AuthService().currentUser;

    int? storeId = args?.storeId;
    int? ownerUserId = args?.ownerUserId;

    if (ownerUserId == null &&
        auth != null &&
        auth.accountType == 'comercio') {
      ownerUserId = auth.id;
    }

    try {
      final store = await _storeService.resolveForProfile(
        storeId: storeId,
        ownerUserId: ownerUserId,
      );
      if (!mounted) return;
      setState(() => _store = store);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Nao foi possivel carregar a loja.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil da Loja')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadStore,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : _store == null
                  ? const Center(
                      child: Text('Nenhuma loja encontrada.'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StoreCard(
                            name: _store!.name,
                            category: _store!.category,
                            address:
                                _store!.address ?? 'Endereco nao informado',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _store!.description?.isNotEmpty == true
                                ? _store!.description!
                                : 'Sem descricao.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Horario: ${_store!.openingHours ?? "Nao informado"}',
                          ),
                          Text(
                            'Contato: ${_store!.contact ?? "Nao informado"}',
                          ),
                        ],
                      ),
                    ),
    );
  }
}
