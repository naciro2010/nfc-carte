import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';

import '../models/business_card.dart';

/// Encodes / decodes deep-link URLs that represent a shared business card.
///
/// Format: `https://nfc-carte.app/c#<base64url(json)>`
///
/// The payload is kept behind the fragment (#) so it is not logged by web
/// servers, and base64url keeps the URL safe for SMS, QR, and chat apps.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  static const scheme = 'https';
  static const host = 'nfc-carte.app';
  static const path = '/c';

  final _controller = StreamController<BusinessCard>.broadcast();
  Stream<BusinessCard> get incomingCards => _controller.stream;

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    _appLinks = AppLinks();
    // Handle launch link
    final initial = await _appLinks!.getInitialLink();
    if (initial != null) _handle(initial);
    // Handle links received while running
    _sub = _appLinks!.uriLinkStream.listen(_handle);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }

  void _handle(Uri uri) {
    final card = decodeUri(uri);
    if (card != null) _controller.add(card);
  }

  /// Returns null if the URI does not match the share format or is corrupt.
  static BusinessCard? decodeUri(Uri uri) {
    if (uri.host != host || !uri.path.startsWith(path)) return null;
    final frag = uri.fragment;
    if (frag.isEmpty) return null;
    try {
      final padded = base64Url.normalize(frag);
      final json = utf8.decode(base64Url.decode(padded));
      final map = jsonDecode(json) as Map<String, dynamic>;
      return BusinessCard.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Uri encodeCard(BusinessCard card) {
    final json = jsonEncode(card.toJson());
    final b64 = base64Url.encode(utf8.encode(json)).replaceAll('=', '');
    return Uri(scheme: scheme, host: host, path: path, fragment: b64);
  }
}
