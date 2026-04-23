import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_carte/models/business_card.dart';
import 'package:nfc_carte/services/vcard_service.dart';

void main() {
  group('VCardService.generate', () {
    test('emits a well-formed VCARD envelope', () {
      final card = BusinessCard(
        id: '1',
        cardName: 'Pro',
        fullName: 'Jane Doe',
        email: 'jane@example.com',
      );
      final vcf = VCardService.generate(card);
      expect(vcf, startsWith('BEGIN:VCARD'));
      expect(vcf, contains('VERSION:3.0'));
      expect(vcf.trim(), endsWith('END:VCARD'));
    });

    test('splits last name from first name(s)', () {
      final card = BusinessCard(
        id: '1',
        cardName: 'x',
        fullName: 'Jean-Paul Martin Dupont',
      );
      final vcf = VCardService.generate(card);
      expect(vcf, contains('N:Dupont;Jean-Paul Martin;;;'));
      expect(vcf, contains('FN:Jean-Paul Martin Dupont'));
    });

    test('single-word name falls back to FN only (N still emitted)', () {
      final card = BusinessCard(id: '1', cardName: 'x', fullName: 'Madonna');
      final vcf = VCardService.generate(card);
      expect(vcf, contains('FN:Madonna'));
      expect(vcf, contains('N:;Madonna;;;'));
    });

    test('omits optional fields when blank', () {
      final card = BusinessCard(id: '1', cardName: 'Empty');
      final vcf = VCardService.generate(card);
      expect(vcf, isNot(contains('EMAIL')));
      expect(vcf, isNot(contains('TEL')));
      expect(vcf, isNot(contains('ORG')));
      expect(vcf, isNot(contains('TITLE')));
      expect(vcf, isNot(contains('ADR')));
      expect(vcf, isNot(contains('URL')));
      expect(vcf, isNot(contains('NOTE')));
    });

    test('escapes special characters per RFC 2426', () {
      final card = BusinessCard(
        id: '1',
        cardName: 'x',
        fullName: 'Smith, John',
        notes: 'Line one\nLine two; with semicolon',
      );
      final vcf = VCardService.generate(card);
      expect(vcf, contains(r'FN:Smith\, John'));
      expect(vcf, contains(r'NOTE:Line one\nLine two\; with semicolon'));
    });

    test('normalises bare-domain URL for LinkedIn', () {
      final card = BusinessCard(
        id: '1',
        cardName: 'x',
        linkedin: 'linkedin.com/in/jane',
      );
      final vcf = VCardService.generate(card);
      expect(vcf, contains('https://linkedin.com/in/jane'));
    });

    test('preserves already-qualified URL', () {
      final card = BusinessCard(
        id: '1',
        cardName: 'x',
        linkedin: 'https://linkedin.com/in/jane',
      );
      final vcf = VCardService.generate(card);
      expect(vcf, contains('https://linkedin.com/in/jane'));
      expect(vcf, isNot(contains('https://https://')));
    });

    test('contains a REV timestamp in ISO 8601 UTC', () {
      final card = BusinessCard(id: '1', cardName: 'x', fullName: 'A B');
      final vcf = VCardService.generate(card);
      final rev = RegExp(r'REV:(\S+)').firstMatch(vcf);
      expect(rev, isNotNull);
      final parsed = DateTime.parse(rev!.group(1)!);
      expect(parsed.isUtc, isTrue);
    });

    test('payload is deterministic except for REV', () {
      final card = BusinessCard(
        id: '1',
        cardName: 'x',
        fullName: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+33 6 12 34 56 78',
      );
      final a = VCardService.generate(card).replaceAll(RegExp(r'REV:\S+\n'), '');
      final b = VCardService.generate(card).replaceAll(RegExp(r'REV:\S+\n'), '');
      expect(a, equals(b));
    });
  });
}
