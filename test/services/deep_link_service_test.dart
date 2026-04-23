import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_carte/models/business_card.dart';
import 'package:nfc_carte/services/deep_link_service.dart';

void main() {
  group('DeepLinkService encode/decode', () {
    test('round-trips a card through an https URL', () {
      final card = BusinessCard(
        id: 'abc',
        cardName: 'Pro',
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+33612345678',
        primaryColor: 0xFFAABBCC,
        templateId: 'minimal',
      );
      final uri = DeepLinkService.encodeCard(card);
      expect(uri.scheme, 'https');
      expect(uri.host, 'nfc-carte.app');
      expect(uri.path, '/c');
      expect(uri.fragment, isNotEmpty);
      expect(uri.toString(), startsWith('https://nfc-carte.app/c#'));

      final decoded = DeepLinkService.decodeUri(uri);
      expect(decoded, isNotNull);
      expect(decoded!.fullName, card.fullName);
      expect(decoded.email, card.email);
      expect(decoded.primaryColor, card.primaryColor);
      expect(decoded.templateId, card.templateId);
    });

    test('returns null for a foreign host', () {
      final uri = Uri.parse('https://evil.example/c#AAA');
      expect(DeepLinkService.decodeUri(uri), isNull);
    });

    test('returns null for a matching host without fragment', () {
      final uri = Uri.parse('https://nfc-carte.app/c');
      expect(DeepLinkService.decodeUri(uri), isNull);
    });

    test('returns null for a corrupt fragment instead of throwing', () {
      final uri = Uri.parse('https://nfc-carte.app/c#not-base64!!!');
      expect(DeepLinkService.decodeUri(uri), isNull);
    });

    test('url is safe for SMS (no +, no /, no =)', () {
      final card = BusinessCard(
        id: 'x',
        cardName: 'x',
        fullName: 'Hello World with spaces and + symbols',
        notes: 'a / b / c',
      );
      final uri = DeepLinkService.encodeCard(card);
      expect(uri.fragment, isNot(contains('+')));
      expect(uri.fragment, isNot(contains('/')));
      expect(uri.fragment, isNot(contains('=')));
    });
  });
}
