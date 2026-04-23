import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/preferences_provider.dart';
import '../providers/cards_provider.dart';
import '../services/consent_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Parametres')),
      body: ListView(
        children: [
          const _SectionHeader('Apparence'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(prefs.themeMode)),
            onTap: () => _pickTheme(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Langue'),
            subtitle: Text(prefs.locale?.languageCode == 'en'
                ? 'English'
                : prefs.locale?.languageCode == 'fr'
                    ? 'Francais'
                    : 'Systeme'),
            onTap: () => _pickLocale(context, ref),
          ),
          const _SectionHeader('Donnees (RGPD)'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Exporter mes donnees'),
            subtitle: const Text('JSON lisible, toutes vos cartes'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined,
                color: Colors.red),
            title: const Text('Supprimer toutes mes donnees',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Revoque le consentement et efface tout'),
            onTap: () => _wipeAll(context, ref),
          ),
          const _SectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Politique de confidentialite'),
            onTap: () => context.push('/privacy'),
          ),
          const _SectionHeader('A propos'),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snap) {
              final v = snap.data;
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text(v == null
                    ? '...'
                    : '${v.version} (${v.buildNumber})'),
              );
            },
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Systeme';
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values
              .map((m) => ListTile(
                    title: Text(m.name),
                    onTap: () => Navigator.pop(context, m),
                  ))
              .toList(),
        ),
      ),
    );
    if (picked != null) {
      await ref.read(preferencesProvider.notifier).setThemeMode(picked);
    }
  }

  Future<void> _pickLocale(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<Locale?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Systeme'),
              onTap: () => Navigator.pop(context, null),
            ),
            ListTile(
              title: const Text('Francais'),
              onTap: () => Navigator.pop(context, const Locale('fr')),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context, const Locale('en')),
            ),
          ],
        ),
      ),
    );
    await ref.read(preferencesProvider.notifier).setLocale(picked);
  }

  Future<void> _exportData(BuildContext context) async {
    final data = StorageService.instance.exportAll();
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/nfc_carte_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    await Share.shareXFiles([XFile(file.path, mimeType: 'application/json')]);
  }

  Future<void> _wipeAll(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tout effacer ?'),
        content: const Text(
          'Toutes vos cartes et preferences seront supprimees. '
          'Vous devrez accepter a nouveau la politique de confidentialite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await StorageService.instance.wipeEverything();
    await ConsentService.instance.revokeConsent();
    ref.invalidate(cardsProvider);
    if (context.mounted) context.go('/consent');
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
