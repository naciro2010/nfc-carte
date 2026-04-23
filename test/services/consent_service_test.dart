import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nfc_carte/models/business_card.dart';
import 'package:nfc_carte/services/consent_service.dart';
import 'package:nfc_carte/services/storage_service.dart';

/// Sets up a minimal isolated Hive environment so we can exercise the real
/// ConsentService against a real (unencrypted, in-memory-ish) prefs box.
Future<Directory> _bootHiveWithPrefs() async {
  final tmp = Directory.systemTemp.createTempSync('nfc_carte_consent_');
  Hive.init(tmp.path);
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(BusinessCardAdapter());
  }
  final prefs = await Hive.openBox<dynamic>('prefs_v1');
  StorageService.instance.debugInject(prefs: prefs);
  return tmp;
}

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await _bootHiveWithPrefs();
  });

  tearDown(() async {
    await Hive.close();
    tmp.deleteSync(recursive: true);
  });

  test('starts without consent', () {
    expect(ConsentService.instance.hasConsented, isFalse);
    expect(ConsentService.instance.acceptedAt, isNull);
  });

  test('acceptConsent flips state and stores a timestamp', () async {
    await ConsentService.instance.acceptConsent();
    expect(ConsentService.instance.hasConsented, isTrue);
    expect(ConsentService.instance.acceptedAt, isA<DateTime>());
  });

  test('revoke clears state', () async {
    await ConsentService.instance.acceptConsent();
    await ConsentService.instance.revokeConsent();
    expect(ConsentService.instance.hasConsented, isFalse);
  });

  test('bumping the privacy version invalidates previous consent', () async {
    await ConsentService.instance.acceptConsent();
    // Simulate a policy version bump by overwriting the stored version.
    await StorageService.instance.prefsBox.put('consent.privacyVersion', -1);
    expect(ConsentService.instance.hasConsented, isFalse);
  });
}
