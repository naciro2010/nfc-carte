import 'storage_service.dart';

/// Tracks explicit user consent (RGPD / GDPR art. 7).
class ConsentService {
  ConsentService._();
  static final ConsentService instance = ConsentService._();

  static const _keyAcceptedAt = 'consent.acceptedAt';
  static const _keyPrivacyVersion = 'consent.privacyVersion';

  /// Bump this when the privacy policy changes materially; users will be
  /// re-prompted for consent.
  static const currentPrivacyVersion = 1;

  bool get hasConsented {
    final prefs = StorageService.instance.prefsBox;
    final accepted = prefs.get(_keyAcceptedAt);
    final version = prefs.get(_keyPrivacyVersion);
    return accepted != null && version == currentPrivacyVersion;
  }

  Future<void> acceptConsent() async {
    final prefs = StorageService.instance.prefsBox;
    await prefs.put(_keyAcceptedAt, DateTime.now().toIso8601String());
    await prefs.put(_keyPrivacyVersion, currentPrivacyVersion);
  }

  Future<void> revokeConsent() async {
    final prefs = StorageService.instance.prefsBox;
    await prefs.delete(_keyAcceptedAt);
    await prefs.delete(_keyPrivacyVersion);
  }

  DateTime? get acceptedAt {
    final raw = StorageService.instance.prefsBox.get(_keyAcceptedAt);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}
