# LocalHub Front-end

Aplicativo mobile em Flutter para conectar usuarios a comercios locais, funcionando como uma rede social para divulgacao de produtos, servicos e promocoes.

## Objetivo

O app permite que:

- clientes encontrem comercios da regiao, filtrem publicacoes e acompanhem o feed;
- comercios se cadastrem, realizem login e acessem o proprio perfil de loja;
- o frontend consuma gradualmente a API do projeto LocalHub.

## Stack

- Flutter
- Dart
- Material 3
- HTTP (`package:http`)

## Estado atual do projeto

O frontend ja esta integrado com o backend para os fluxos principais abaixo:

- cadastro de usuario via `POST /api/auth/register`
- login via `POST /api/auth/login`
- carregamento do feed via `GET /api/posts`
- carregamento do perfil de loja via `GET /api/stores` e `GET /api/stores/:id`

Atualmente o app **nao usa mocks ativos no codigo Dart** para login, cadastro, feed ou perfil da loja.

## Estrutura atual

```text
lib/
  core/
    constants/
      app_colors.dart
      app_routes.dart
    theme/
      app_theme.dart
    utils/
  models/
    category_model.dart
    post_model.dart
    store_model.dart
    user_model.dart
  services/
    api_service.dart
    auth_service.dart
    post_service.dart
    store_service.dart
  widgets/
    custom_button.dart
    custom_text_field.dart
    post_card.dart
    store_card.dart
  screens/
    splash/
      splash_screen.dart
    auth/
      login_screen.dart
      register_screen.dart
    home/
      home_screen.dart
    store/
      store_profile_screen.dart
    profile/
      user_profile_screen.dart
  main.dart
```

## Rotas configuradas

- `/` -> `SplashScreen`
- `/login` -> `LoginScreen`
- `/register` -> `RegisterScreen`
- `/home` -> `HomeScreen`
- `/store-profile` -> `StoreProfileScreen`

## Fluxo atual implementado

1. App inicia na `SplashScreen`
2. Splash redireciona para `LoginScreen`
3. Usuario pode abrir `RegisterScreen`
4. Cadastro envia dados reais para a API
5. Login envia credenciais reais para a API
6. Se o usuario for `cliente`, navega para `HomeScreen`
7. Se o usuario for `comercio`, navega para `StoreProfileScreen`
8. O feed carrega posts reais da API e monta categorias dinamicamente

## Tema e design system

O tema base esta centralizado em:

- `lib/core/constants/app_colors.dart`
- `lib/core/theme/app_theme.dart`

A paleta principal contempla:

- `primary`: azul institucional
- `secondary` e `tertiary`: tons de apoio
- `accent`: laranja para destaque
- cores de fundo, superficie, borda e textos

O app utiliza `ThemeData` com `Material 3`.

## Configuracao da API

O frontend usa `API_BASE_URL` via `--dart-define` quando informado.

Exemplo:

```bash
flutter run --dart-define=API_BASE_URL=http://SEU_HOST:3000/api
```

Se a variavel nao for informada, o app usa um valor padrao por plataforma:

- Android emulator: `http://10.0.2.2:3000/api`
- iOS simulator: `http://127.0.0.1:3000/api`
- desktop/web: `http://localhost:3000/api`

### Observacao importante

Em **celular fisico**, normalmente voce precisa informar manualmente o IP da sua maquina:

```bash
flutter run --dart-define=API_BASE_URL=http://IP_DO_PC:3000/api
```

## Como rodar localmente

### Pre-requisitos

- Flutter SDK instalado
- backend do LocalHub rodando
- emulador Android/iOS, desktop ou dispositivo fisico

### Comandos

```bash
flutter pub get
flutter run
```

Se quiser forcar a URL da API:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

## Validacao

Para validar o projeto:

```bash
flutter analyze
flutter test
```

## Observacoes de desenvolvimento

- Android esta configurado para permitir trafego HTTP local em ambiente de desenvolvimento.
- iOS possui configuracao para acesso a rede local.
- O `AuthService` mantem o usuario atual em memoria durante a sessao do app.
- O perfil da loja pode ser resolvido pelo `ownerUserId` do usuario autenticado.

## Proximos passos

- integrar busca de comercios por categoria
- implementar curtidas em posts
- conectar criacao/edicao de perfil de loja
- conectar criacao/edicao/exclusao de posts
- adicionar tratamento de sessao/persistencia local, se o projeto passar a exigir