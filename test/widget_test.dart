import 'package:flutter_test/flutter_test.dart';

import 'package:localhub_front/main.dart';

void main() {
  testWidgets('App inicia na splash e navega para login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('LocalHub'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Esqueceu a senha?'), findsOneWidget);
  });
}
