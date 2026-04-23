import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/business_card.dart';
import 'deep_link_service.dart';
import 'vcard_service.dart';

/// Handles platform sharing: vCard file, plain-text link, raw payload.
class ShareService {
  static Future<void> shareVCard(BusinessCard card) async {
    final vcard = VCardService.generate(card);
    final dir = await getTemporaryDirectory();
    final safeName =
        card.fullName.isEmpty ? 'contact' : card.fullName.replaceAll(' ', '_');
    final file = File('${dir.path}/$safeName.vcf');
    await file.writeAsString(vcard);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/vcard')],
      subject: card.fullName,
    );
  }

  static Future<void> sharePlainText(BusinessCard card) async {
    final buf = StringBuffer();
    if (card.fullName.isNotEmpty) buf.writeln(card.fullName);
    if (card.jobTitle.isNotEmpty) buf.writeln(card.jobTitle);
    if (card.company.isNotEmpty) buf.writeln(card.company);
    if (card.email.isNotEmpty) buf.writeln(card.email);
    if (card.phone.isNotEmpty) buf.writeln(card.phone);
    if (card.website.isNotEmpty) buf.writeln(card.website);
    await Share.share(buf.toString().trim());
  }

  static Future<void> shareDeepLink(BusinessCard card) async {
    final uri = DeepLinkService.encodeCard(card);
    await Share.share(
      uri.toString(),
      subject: card.fullName,
    );
  }
}
