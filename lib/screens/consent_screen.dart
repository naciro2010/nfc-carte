import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/consent_service.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.shield_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Votre vie privee d\'abord',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Toutes vos donnees sont stockees localement sur cet appareil, '
                'dans une base chiffree dont la cle vit dans le coffre-fort du '
                'telephone (iOS Keychain / Android Keystore).\n\n'
                'Aucune donnee n\'est envoyee a un serveur. '
                'Vous pouvez exporter ou effacer vos donnees a tout moment depuis les Parametres.\n\n'
                'En continuant, vous reconnaissez avoir lu notre politique de confidentialite.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/privacy'),
                child: const Text('Lire la politique de confidentialite'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await ConsentService.instance.acceptConsent();
                  if (context.mounted) context.go('/home');
                },
                child: const Text('J\'accepte et je continue'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
