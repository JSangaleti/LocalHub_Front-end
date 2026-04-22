# LocalHub Front-end

Aplicativo mobile em Flutter para conectar usuarios a comercios locais, funcionando como uma rede social de divulgacao de produtos, servicos e promocoes.

## Objetivo

O app permite que clientes encontrem comercios da regiao e acompanhem publicacoes, enquanto comercios podem criar perfil e divulgar conteudo.

## Stack

- Flutter
- Dart
- Material 3

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
  services/
  widgets/
  screens/
    splash/
    auth/
    home/
    store/
    profile/
  mock/
  main.dart
```

## Rotas configuradas

- `/` -> Splash
- `/login` -> Login
- `/register` -> Cadastro
- `/home` -> Feed inicial
- `/store-profile` -> Perfil da loja

## Tema e design system

O tema base esta centralizado em:

- `lib/core/constants/app_colors.dart`
- `lib/core/theme/app_theme.dart`

A paleta principal contempla:

- `primary`: azul institucional
- `secondary` e `tertiary`: tons de apoio para destaque
- `accent`: laranja para acao secundaria
- cores de fundo, superficie, borda e textos

## Fluxo atual implementado

1. App inicia na `SplashScreen`
2. Redireciona para `LoginScreen`
3. Login navega para `HomeScreen`
4. Cadastro possui selecao de tipo de conta (`cliente` ou `comercio`)

> Observacao: nesta fase, o app usa dados locais/mock e ainda nao depende de backend real.

## Como rodar localmente

### Pre-requisitos

- Flutter SDK instalado
- Emulador Android/iOS ou dispositivo fisico

### Comandos

```bash
flutter pub get
flutter run
```

## Qualidade e validacao

Rodar analise estatica e testes:

```bash
flutter analyze
flutter test
```
- Implementar busca de comercios por categoria
- Conectar gradualmente com a API do backend quando estiver disponivel
