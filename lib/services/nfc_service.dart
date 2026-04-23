import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../models/business_card.dart';
import 'vcard_service.dart';

class NfcResult {
  const NfcResult({required this.success, this.message, this.payload});
  final bool success;
  final String? message;
  final String? payload;
}

/// Reads and writes NDEF tags carrying vCard payloads.
///
/// Requires:
///  - iOS: NFCReaderUsageDescription + Core NFC tag reading entitlement
///  - Android: android.permission.NFC
class NfcService {
  static Future<bool> get isAvailable => NfcManager.instance.isAvailable();

  /// Starts an NFC session and writes the vCard when a writable NDEF tag is
  /// held near the device. The session is closed automatically.
  static Future<void> writeCardToTag(
    BusinessCard card, {
    required void Function(String message) onStatus,
    required void Function(String error) onError,
  }) async {
    if (!await isAvailable) {
      onError('NFC indisponible sur cet appareil');
      return;
    }

    final vcard = VCardService.generate(card);
    final record = NdefRecord.createMime(
      'text/vcard',
      Uint8List.fromList(utf8.encode(vcard)),
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
          if (message.byteLength > ndef.maxSize) {
            await NfcManager.instance.stopSession(
              errorMessage: 'Tag trop petit',
            );
            onError(
              'Tag trop petit (${ndef.maxSize} octets disponibles, '
              '${message.byteLength} requis)',
            );
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

  /// Reads the first NDEF message from a tag and returns its string payload.
  static Future<void> readTag({
    required void Function(String payload) onRead,
    required void Function(String error) onError,
  }) async {
    if (!await isAvailable) {
      onError('NFC indisponible');
      return;
    }
    await NfcManager.instance.startSession(
      alertMessage: 'Approchez un tag NFC',
      onDiscovered: (tag) async {
        try {
          final ndef = Ndef.from(tag);
          final cached = ndef?.cachedMessage;
          if (cached == null || cached.records.isEmpty) {
            await NfcManager.instance.stopSession(
              errorMessage: 'Tag vide',
            );
            onError('Tag vide');
            return;
          }
          final record = cached.records.first;
          final payload = utf8.decode(record.payload, allowMalformed: true);
          await NfcManager.instance.stopSession(alertMessage: 'Lu');
          onRead(payload);
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: 'Echec');
          onError(e.toString());
        }
      },
    );
  }

  static Future<void> cancel() => NfcManager.instance.stopSession();
}
