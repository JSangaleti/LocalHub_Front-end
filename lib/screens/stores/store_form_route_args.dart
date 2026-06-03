/// Argumentos ao abrir [StoreFormScreen] para cadastro pelo usuário logado.
class StoreFormRouteArgs {
  final int ownerUserId;
  final bool lockOwnerId;

  const StoreFormRouteArgs({
    required this.ownerUserId,
    this.lockOwnerId = true,
  });
}
