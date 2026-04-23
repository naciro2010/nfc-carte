import '../models/business_card.dart';

/// Generates a vCard 3.0 compliant payload (RFC 2426) from a BusinessCard.
///
/// vCard is the standard contact format understood by iOS Contacts, Android
/// Contacts, macOS, Outlook, etc. It is also supported as an NDEF MIME
/// record for NFC tags (`text/vcard`).
class VCardService {
  static String generate(BusinessCard c) {
    final sb = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0');

    if (c.fullName.isNotEmpty) {
      sb.writeln('FN:${_escape(c.fullName)}');
      final parts = c.fullName.split(' ');
      final last = parts.length > 1 ? parts.last : '';
      final first = parts.length > 1
          ? parts.sublist(0, parts.length - 1).join(' ')
          : c.fullName;
      sb.writeln('N:${_escape(last)};${_escape(first)};;;');
    }
    if (c.jobTitle.isNotEmpty) sb.writeln('TITLE:${_escape(c.jobTitle)}');
    if (c.company.isNotEmpty) sb.writeln('ORG:${_escape(c.company)}');
    if (c.email.isNotEmpty) sb.writeln('EMAIL;TYPE=INTERNET:${_escape(c.email)}');
    if (c.phone.isNotEmpty) sb.writeln('TEL;TYPE=CELL:${_escape(c.phone)}');
    if (c.website.isNotEmpty) sb.writeln('URL:${_escape(c.website)}');
    if (c.address.isNotEmpty) {
      sb.writeln('ADR;TYPE=WORK:;;${_escape(c.address)};;;;');
    }
    if (c.linkedin.isNotEmpty) {
      sb.writeln('URL;TYPE=LinkedIn:${_escape(_normalizeUrl(c.linkedin))}');
    }
    if (c.twitter.isNotEmpty) {
      sb.writeln('X-SOCIALPROFILE;TYPE=twitter:${_escape(c.twitter)}');
    }
    if (c.instagram.isNotEmpty) {
      sb.writeln('X-SOCIALPROFILE;TYPE=instagram:${_escape(c.instagram)}');
    }
    if (c.notes.isNotEmpty) sb.writeln('NOTE:${_escape(c.notes)}');

    sb
      ..writeln('REV:${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('END:VCARD');

    return sb.toString();
  }

  static String _escape(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\n', r'\n');
  }

  static String _normalizeUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://$url';
  }
}
