import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_carte/screens/consent_screen.dart';
import 'package:nfc_carte/services/consent_service.dart';

import '../helpers/test_harness.dart';

void main() {
  late TestHarness harness;

  setUp(() async {
    harness = await TestHarness.boot();
  });

  tearDown(() async {
    await harness.tearDown();
  });

  GoRouter _router({required String initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/consent', builder: (_, __) => const ConsentScreen()),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: '/privacy',
          builder: (_, __) => const Scaffold(body: Text('PRIVACY')),
        ),
      ],
    );
  }

  testWidgets('shows privacy CTA and accept button', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: _router(initialLocation: '/consent'),
    ));
    expect(find.text('Votre vie privee d\'abord'), findsOneWidget);
    expect(find.text('J\'accepte et je continue'), findsOneWidget);
    expect(find.text('Lire la politique de confidentialite'), findsOneWidget);
  });

  testWidgets('accept records consent and navigates home', (tester) async {
    expect(ConsentService.instance.hasConsented, isFalse);

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: _router(initialLocation: '/consent'),
    ));

    await tester.tap(find.text('J\'accepte et je continue'));
    await tester.pumpAndSettle();

    expect(ConsentService.instance.hasConsented, isTrue);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('privacy link navigates to privacy screen', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: _router(initialLocation: '/consent'),
    ));
    await tester.tap(find.text('Lire la politique de confidentialite'));
    await tester.pumpAndSettle();
    expect(find.text('PRIVACY'), findsOneWidget);
  });
}
