import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nfc_carte/app.dart';
import 'package:nfc_carte/models/business_card.dart';
import 'package:nfc_carte/services/consent_service.dart';
import 'package:nfc_carte/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BusinessCardAdapter());
    }
    await StorageService.instance.init();
    await ConsentService.instance.revokeConsent();
    await StorageService.instance.wipeEverything();
  });

  testWidgets('first-launch journey: consent -> create -> save -> appears',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NfcCarteApp()));
    await tester.pumpAndSettle();

    // Consent screen gates the app.
    expect(find.text('Votre vie privee d\'abord'), findsOneWidget);
    await tester.tap(find.text('J\'accepte et je continue'));
    await tester.pumpAndSettle();

    // Home, empty state.
    expect(find.text('Aucune carte'), findsOneWidget);
    await tester.tap(find.text('Creer une carte'));
    await tester.pumpAndSettle();

    // Editor: fill in minimal fields.
    final fullNameField = find.widgetWithText(TextFormField, 'Nom complet');
    expect(fullNameField, findsOneWidget);
    await tester.enterText(fullNameField, 'Jane Doe');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jane@doe.com',
    );
    await tester.pumpAndSettle();

    // Save.
    await tester.tap(find.text('Enregistrer').last);
    await tester.pumpAndSettle();

    // Back on home, the card is visible.
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets('consent persists across app restarts', (tester) async {
    await ConsentService.instance.acceptConsent();
    await tester.pumpWidget(const ProviderScope(child: NfcCarteApp()));
    await tester.pumpAndSettle();
    expect(find.text('Aucune carte'), findsOneWidget);
  });
}
