import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/business_card.dart';

/// Local-first storage. All user data stays on-device.
///
/// - Business cards are stored in an encrypted Hive box. The encryption key
///   itself is stored in the platform secure enclave (iOS Keychain / Android
///   Keystore) via `flutter_secure_storage`.
/// - Preferences (consent, locale, theme) are in an unencrypted Hive box.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _cardsBoxName = 'cards_v1';
  static const _prefsBoxName = 'prefs_v1';
  static const _secureKeyName = 'hive_cards_key_v1';

  late Box<BusinessCard> _cards;
  late Box<dynamic> _prefs;

  Box<BusinessCard> get cardsBox => _cards;
  Box<dynamic> get prefsBox => _prefs;

  Future<void> init() async {
    final secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    var base64Key = await secure.read(key: _secureKeyName);
    if (base64Key == null) {
      final key = Hive.generateSecureKey();
      base64Key = base64UrlEncode(key);
      await secure.write(key: _secureKeyName, value: base64Key);
    }
    final encryptionKey = base64Url.decode(base64Key);

    _cards = await Hive.openBox<BusinessCard>(
      _cardsBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    _prefs = await Hive.openBox<dynamic>(_prefsBoxName);
  }

  Future<void> wipeEverything() async {
    await _cards.clear();
    await _prefs.clear();
  }

  Map<String, dynamic> exportAll() => {
        'schemaVersion': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'cards': _cards.values.map((c) => c.toJson()).toList(),
      };
}
