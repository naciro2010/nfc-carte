import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(PreferencesState.load());

  static const _keyThemeMode = 'prefs.themeMode';
  static const _keyLocale = 'prefs.locale';

  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.instance.prefsBox.put(_keyThemeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale? locale) async {
    await StorageService.instance.prefsBox
        .put(_keyLocale, locale?.languageCode);
    state = state.copyWith(locale: locale, clearLocale: locale == null);
  }
}

class PreferencesState {
  PreferencesState({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;
  final Locale? locale;

  static PreferencesState load() {
    final box = StorageService.instance.prefsBox;
    final rawTheme = box.get(PreferencesNotifier._keyThemeMode) as String?;
    final rawLocale = box.get(PreferencesNotifier._keyLocale) as String?;
    return PreferencesState(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == rawTheme,
        orElse: () => ThemeMode.system,
      ),
      locale: rawLocale != null ? Locale(rawLocale) : null,
    );
  }

  PreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
    );
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>(
  (ref) => PreferencesNotifier(),
);
