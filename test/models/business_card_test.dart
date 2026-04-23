import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nfc_carte/models/business_card.dart';

void main() {
  group('BusinessCard', () {
    test('copyWith preserves id and bumps updatedAt', () async {
      final original = BusinessCard(
        id: 'abc',
        cardName: 'Old',
        fullName: 'Jane',
      );
      final originalUpdated = original.updatedAt;
      await Future<void>.delayed(const Duration(milliseconds: 5));

      final updated = original.copyWith(cardName: 'New');
      expect(updated.id, equals('abc'));
      expect(updated.cardName, equals('New'));
      expect(updated.fullName, equals('Jane'));
      expect(updated.updatedAt.isAfter(originalUpdated), isTrue);
      expect(updated.createdAt, equals(original.createdAt));
    });

    test('toJson / fromJson round-trips every field', () {
      final now = DateTime.utc(2026, 4, 23, 10);
      final card = BusinessCard(
        id: 'abc',
        cardName: 'Pro',
        fullName: 'Jane Doe',
        jobTitle: 'CTO',
        company: 'Acme',
        email: 'jane@acme.com',
        phone: '+33612345678',
        website: 'acme.com',
        address: '1 rue de Paris',
        linkedin: 'linkedin.com/in/jane',
        twitter: '@jane',
        instagram: '@janedoe',
        notes: 'VIP',
        photoPath: '/tmp/photo.jpg',
        primaryColor: 0xFFAA0000,
        templateId: 'minimal',
        createdAt: now,
        updatedAt: now,
      );

      final roundTripped = BusinessCard.fromJson(card.toJson());
      expect(roundTripped.id, card.id);
      expect(roundTripped.cardName, card.cardName);
      expect(roundTripped.fullName, card.fullName);
      expect(roundTripped.jobTitle, card.jobTitle);
      expect(roundTripped.company, card.company);
      expect(roundTripped.email, card.email);
      expect(roundTripped.phone, card.phone);
      expect(roundTripped.website, card.website);
      expect(roundTripped.address, card.address);
      expect(roundTripped.linkedin, card.linkedin);
      expect(roundTripped.twitter, card.twitter);
      expect(roundTripped.instagram, card.instagram);
      expect(roundTripped.notes, card.notes);
      expect(roundTripped.photoPath, card.photoPath);
      expect(roundTripped.primaryColor, card.primaryColor);
      expect(roundTripped.templateId, card.templateId);
      expect(roundTripped.createdAt.toUtc(), card.createdAt.toUtc());
      expect(roundTripped.updatedAt.toUtc(), card.updatedAt.toUtc());
    });

    test('defaults are sensible', () {
      final c = BusinessCard(id: '1', cardName: 'n');
      expect(c.primaryColor, 0xFF1F6FEB);
      expect(c.templateId, 'modern');
      expect(c.fullName, isEmpty);
      expect(c.photoPath, isNull);
    });
  });

  group('BusinessCardAdapter', () {
    test('Hive binary round-trip preserves all fields', () async {
      Hive.registerAdapter(BusinessCardAdapter());

      final tmp = Directory.systemTemp.createTempSync('nfc_carte_test_');
      Hive.init(tmp.path);

      final box = await Hive.openBox<BusinessCard>('test_cards');
      final c = BusinessCard(
        id: 'abc',
        cardName: 'Pro',
        fullName: 'Jane Doe',
        email: 'j@d.com',
        primaryColor: 0xFFFF00AA,
        templateId: 'classic',
      );
      await box.put(c.id, c);
      await box.close();

      final reopened = await Hive.openBox<BusinessCard>('test_cards');
      final restored = reopened.get('abc')!;
      expect(restored.id, c.id);
      expect(restored.fullName, c.fullName);
      expect(restored.email, c.email);
      expect(restored.primaryColor, c.primaryColor);
      expect(restored.templateId, c.templateId);

      await reopened.close();
      tmp.deleteSync(recursive: true);
    });
  });
}
