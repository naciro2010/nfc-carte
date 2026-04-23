import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nfc_carte/models/business_card.dart';
import 'package:nfc_carte/services/storage_service.dart';

/// Shared test setup: boots Hive in a temp dir and wires the real
/// StorageService to throw-away boxes so providers behave realistically
/// without the platform secure storage dependency.
class TestHarness {
  TestHarness._(this.tmp);
  final Directory tmp;

  static Future<TestHarness> boot() async {
    final tmp = Directory.systemTemp.createTempSync('nfc_carte_test_');
    Hive.init(tmp.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BusinessCardAdapter());
    }
    final cards = await Hive.openBox<BusinessCard>('cards_v1_test');
    final prefs = await Hive.openBox<dynamic>('prefs_v1_test');
    StorageService.instance.debugInject(cards: cards, prefs: prefs);
    return TestHarness._(tmp);
  }

  Future<void> tearDown() async {
    await Hive.close();
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  }

  Widget wrap(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );
  }
}

Future<void> pumpAndSettleFast(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
