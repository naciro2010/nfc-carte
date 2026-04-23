import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/preferences_provider.dart';
import 'screens/card_editor_screen.dart';
import 'screens/card_view_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/consent_service.dart';
import 'theme/app_theme.dart';

class NfcCarteApp extends ConsumerWidget {
  const NfcCarteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final router = _buildRouter();

    return MaterialApp.router(
      title: 'NFC Carte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: prefs.themeMode,
      locale: prefs.locale,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final hasConsent = ConsentService.instance.hasConsented;
        final atConsent = state.matchedLocation == '/consent';
        final atSplash = state.matchedLocation == '/';
        final atPrivacy = state.matchedLocation == '/privacy';
        if (!hasConsent && !atConsent && !atSplash && !atPrivacy) {
          return '/consent';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/consent', builder: (_, __) => const ConsentScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/card/:id',
          builder: (_, s) => CardViewScreen(cardId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/card/:id/edit',
          builder: (_, s) =>
              CardEditorScreen(cardId: s.pathParameters['id']!),
        ),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/privacy', builder: (_, __) => const PrivacyScreen()),
      ],
    );
  }
}
