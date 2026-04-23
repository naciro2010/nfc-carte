import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_carte/models/business_card.dart';
import 'package:nfc_carte/widgets/card_preview.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders full name when provided', (tester) async {
    final card = BusinessCard(
      id: '1',
      cardName: 'fallback',
      fullName: 'Jane Doe',
      jobTitle: 'CTO',
      company: 'Acme',
    );
    await tester.pumpWidget(wrap(CardPreview(card: card)));
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('CTO'), findsOneWidget);
    expect(find.text('Acme'), findsOneWidget);
  });

  testWidgets('falls back to cardName when fullName is empty', (tester) async {
    final card = BusinessCard(id: '1', cardName: 'My Card');
    await tester.pumpWidget(wrap(CardPreview(card: card)));
    expect(find.text('My Card'), findsOneWidget);
  });

  testWidgets('shows initials avatar when no photo is set', (tester) async {
    final card = BusinessCard(id: '1', cardName: 'x', fullName: 'Ada Lovelace');
    await tester.pumpWidget(wrap(CardPreview(card: card)));
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('renders email only in expanded form', (tester) async {
    final card = BusinessCard(
      id: '1',
      cardName: 'x',
      fullName: 'Jane',
      email: 'j@example.com',
    );
    await tester.pumpWidget(wrap(CardPreview(card: card)));
    expect(find.text('j@example.com'), findsOneWidget);

    await tester.pumpWidget(wrap(CardPreview(card: card, compact: true)));
    expect(find.text('j@example.com'), findsNothing);
  });

  testWidgets('each template variant builds without exception', (tester) async {
    for (final template in const ['modern', 'classic', 'minimal']) {
      final card = BusinessCard(
        id: template,
        cardName: 'x',
        fullName: 'Test User',
        templateId: template,
      );
      await tester.pumpWidget(wrap(CardPreview(card: card)));
      expect(tester.takeException(), isNull, reason: 'template=$template');
    }
  });
}
