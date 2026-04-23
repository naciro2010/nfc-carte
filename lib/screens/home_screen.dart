import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cards_provider.dart';
import '../widgets/card_preview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes cartes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: cards.isEmpty
          ? _EmptyState(onCreate: () => _createCard(context, ref))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final card = cards[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push('/card/${card.id}'),
                  child: CardPreview(card: card),
                );
              },
            ),
      floatingActionButton: cards.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _createCard(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle carte'),
            ),
    );
  }

  Future<void> _createCard(BuildContext context, WidgetRef ref) async {
    final card = await ref.read(cardsProvider.notifier).create();
    if (context.mounted) context.push('/card/${card.id}/edit');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune carte',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Creez votre premiere carte de visite numerique.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Creer une carte'),
            ),
          ],
        ),
      ),
    );
  }
}
