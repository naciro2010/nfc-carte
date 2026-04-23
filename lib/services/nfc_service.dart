import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../models/business_card.dart';
import 'vcard_service.dart';

/// Writes an NDEF message containing a vCard to an NFC tag.
///
/// Requires:
///  - iOS: NFCReaderUsageDescription + Core NFC tag reading entitlement
///  - Android: android.permission.NFC
class NfcService {
  static Future<bool> get isAvailable => NfcManager.instance.isAvailable();

  /// Starts an NFC session, writes the vCard when a writable NDEF tag is held
  /// near the device, then stops the session. Returns true on success.
  static Future<void> writeCardToTag(
    BusinessCard card, {
    required void Function(String message) onStatus,
    required void Function(String error) onError,
  }) async {
    final available = await isAvailable;
    if (!available) {
      onError('NFC indisponible sur cet appareil');
      return;
    }

    final vcard = VCardService.generate(card);
    final record = NdefRecord.createMime(
      'text/vcard',
      Uint8List.fromList(vcard.codeUnits),
    );
    final message = NdefMessage([record]);

    await NfcManager.instance.startSession(
      alertMessage: 'Approchez un tag NFC',
      onDiscovered: (tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            await NfcManager.instance.stopSession(
              errorMessage: 'Tag non inscriptible',
            );
            onError('Tag non inscriptible');
            return;
          }
          await ndef.write(message);
          await NfcManager.instance.stopSession(alertMessage: 'Ecrit !');
          onStatus('Ecriture reussie');
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: 'Echec');
          onError(e.toString());
        }
      },
    );
  }

  static Future<void> cancel() => NfcManager.instance.stopSession();
}
