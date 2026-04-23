import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business_card.dart';
import '../providers/cards_provider.dart';
import '../services/nfc_service.dart';
import '../services/share_service.dart';
import '../services/vcard_service.dart';
import '../widgets/card_preview.dart';

class CardViewScreen extends ConsumerWidget {
  const CardViewScreen({super.key, required this.cardId});
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(cardByIdProvider(cardId));
    if (card == null) {
      return const Scaffold(
        body: Center(child: Text('Carte introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(card.cardName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/card/${card.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, card.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardPreview(card: card),
          const SizedBox(height: 24),
          _QrBlock(card: card),
          const SizedBox(height: 24),
          _InfoList(card: card),
          const SizedBox(height: 24),
          _ShareActions(card: card),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette carte ?'),
        content: const Text('Cette action est irreversible.'),
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
    if (confirm == true) {
      await ref.read(cardsProvider.notifier).remove(id);
      if (context.mounted) context.pop();
    }
  }
}

class _QrBlock extends StatelessWidget {
  const _QrBlock({required this.card});
  final BusinessCard card;

  @override
  Widget build(BuildContext context) {
    final payload = VCardService.generate(card);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Scanner pour ajouter',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: payload,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoList extends StatelessWidget {
  const _InfoList({required this.card});
  final BusinessCard card;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      if (card.email.isNotEmpty)
        _InfoRow(Icons.email_outlined, card.email, 'mailto:${card.email}'),
      if (card.phone.isNotEmpty)
        _InfoRow(Icons.phone_outlined, card.phone, 'tel:${card.phone}'),
      if (card.website.isNotEmpty)
        _InfoRow(Icons.public_outlined, card.website,
            _normalizeUrl(card.website)),
      if (card.address.isNotEmpty)
        _InfoRow(Icons.place_outlined, card.address, null),
      if (card.linkedin.isNotEmpty)
        _InfoRow(Icons.business_center_outlined, card.linkedin,
            _normalizeUrl(card.linkedin)),
      if (card.twitter.isNotEmpty)
        _InfoRow(Icons.alternate_email, card.twitter, null),
      if (card.instagram.isNotEmpty)
        _InfoRow(Icons.camera_alt_outlined, card.instagram, null),
      if (card.notes.isNotEmpty)
        _InfoRow(Icons.notes_outlined, card.notes, null),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Column(children: rows),
    );
  }

  static String _normalizeUrl(String url) {
    if (url.startsWith('http')) return url;
    return 'https://$url';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.url);
  final IconData icon;
  final String label;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: url == null
          ? null
          : () => launchUrl(Uri.parse(url!),
              mode: LaunchMode.externalApplication),
    );
  }
}

class _ShareActions extends StatelessWidget {
  const _ShareActions({required this.card});
  final BusinessCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () => ShareService.shareVCard(card),
          icon: const Icon(Icons.contact_page_outlined),
          label: const Text('Partager contact (vCard)'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => ShareService.sharePlainText(card),
          icon: const Icon(Icons.ios_share),
          label: const Text('Partager en texte'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _writeNfc(context, card),
          icon: const Icon(Icons.nfc),
          label: const Text('Ecrire sur un tag NFC'),
        ),
      ],
    );
  }

  Future<void> _writeNfc(BuildContext context, BusinessCard card) async {
    final messenger = ScaffoldMessenger.of(context);
    await NfcService.writeCardToTag(
      card,
      onStatus: (m) => messenger.showSnackBar(SnackBar(content: Text(m))),
      onError: (e) => messenger.showSnackBar(
        SnackBar(content: Text('Erreur NFC : $e')),
      ),
    );
  }
}
