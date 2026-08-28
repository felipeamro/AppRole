// Smoke test: garante que o app sobe e mostra a tela de Onboarding.

import 'package:flutter_test/flutter_test.dart';

import 'package:ivibe/main.dart';

void main() {
  testWidgets('App inicia na tela de Onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const IVibeApp());

    expect(find.text('Bem-vindo ao iVibe'), findsOneWidget);
    expect(find.text('Pinheiros'), findsOneWidget);
  });
}
