import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_carte/providers/cards_provider.dart';
import 'package:nfc_carte/screens/home_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  late TestHarness harness;

  setUp(() async {
    harness = await TestHarness.boot();
  });

  tearDown(() async {
    await harness.tearDown();
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('SETTINGS')),
        ),
        GoRoute(
          path: '/card/:id',
          builder: (_, s) =>
              Scaffold(body: Text('VIEW ${s.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/card/:id/edit',
          builder: (_, s) =>
              Scaffold(body: Text('EDIT ${s.pathParameters['id']}')),
        ),
      ],
    );
  }

  Widget app() => ProviderScope(
        child: MaterialApp.router(routerConfig: buildRouter()),
      );

  testWidgets('empty state invites the user to create a card', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Aucune carte'), findsOneWidget);
    expect(find.text('Creer une carte'), findsOneWidget);
  });

  testWidgets('tapping empty-state CTA creates a card and opens the editor',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Creer une carte'));
    await tester.pumpAndSettle();

    expect(find.textContaining('EDIT '), findsOneWidget);
  });

  testWidgets('existing cards render as tiles on the home screen',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await container.read(cardsProvider.notifier).create(cardName: 'Preseeded');
    await tester.pumpAndSettle();

    expect(find.text('Preseeded'), findsOneWidget);
  });
}
