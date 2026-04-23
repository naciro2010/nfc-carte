import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/business_card.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_preview.dart';

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({super.key, required this.cardId});
  final String cardId;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  late BusinessCard _draft;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final existing = ref.read(cardsProvider.notifier).byId(widget.cardId);
    _draft = existing ?? BusinessCard(id: widget.cardId, cardName: 'Carte');
  }

  void _update(BusinessCard Function(BusinessCard) mutate) {
    setState(() => _draft = mutate(_draft));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(cardsProvider.notifier).update(_draft);
    if (mounted) context.pop();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (img != null) {
      _update((c) => c.copyWith(photoPath: img.path));
    }
  }

  Future<void> _pickColor() async {
    Color picked = Color(_draft.primaryColor);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Couleur de la carte'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => picked = c,
            enableAlpha: false,
            labelTypes: const <ColorLabelType>[],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              _update((c) => c.copyWith(primaryColor: picked.value));
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CardPreview(card: _draft),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_outlined),
                    label: const Text('Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickColor,
                    icon: const Icon(Icons.palette_outlined),
                    label: const Text('Couleur'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _templateSelector(),
            const SizedBox(height: 24),
            _field(
              label: 'Nom de la carte',
              initial: _draft.cardName,
              onChanged: (v) => _update((c) => c.copyWith(cardName: v)),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Requis' : null,
            ),
            _field(
              label: 'Nom complet',
              initial: _draft.fullName,
              onChanged: (v) => _update((c) => c.copyWith(fullName: v)),
            ),
            _field(
              label: 'Poste',
              initial: _draft.jobTitle,
              onChanged: (v) => _update((c) => c.copyWith(jobTitle: v)),
            ),
            _field(
              label: 'Entreprise',
              initial: _draft.company,
              onChanged: (v) => _update((c) => c.copyWith(company: v)),
            ),
            _field(
              label: 'Email',
              initial: _draft.email,
              keyboard: TextInputType.emailAddress,
              onChanged: (v) => _update((c) => c.copyWith(email: v)),
            ),
            _field(
              label: 'Telephone',
              initial: _draft.phone,
              keyboard: TextInputType.phone,
              onChanged: (v) => _update((c) => c.copyWith(phone: v)),
            ),
            _field(
              label: 'Site web',
              initial: _draft.website,
              keyboard: TextInputType.url,
              onChanged: (v) => _update((c) => c.copyWith(website: v)),
            ),
            _field(
              label: 'Adresse',
              initial: _draft.address,
              onChanged: (v) => _update((c) => c.copyWith(address: v)),
            ),
            _field(
              label: 'LinkedIn',
              initial: _draft.linkedin,
              onChanged: (v) => _update((c) => c.copyWith(linkedin: v)),
            ),
            _field(
              label: 'X / Twitter',
              initial: _draft.twitter,
              onChanged: (v) => _update((c) => c.copyWith(twitter: v)),
            ),
            _field(
              label: 'Instagram',
              initial: _draft.instagram,
              onChanged: (v) => _update((c) => c.copyWith(instagram: v)),
            ),
            _field(
              label: 'Notes',
              initial: _draft.notes,
              maxLines: 3,
              onChanged: (v) => _update((c) => c.copyWith(notes: v)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _templateSelector() {
    const templates = ['modern', 'classic', 'minimal'];
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'modern', label: Text('Moderne')),
        ButtonSegment(value: 'classic', label: Text('Classique')),
        ButtonSegment(value: 'minimal', label: Text('Minimal')),
      ],
      selected: {_draft.templateId.isEmpty ? 'modern' : _draft.templateId}
          .where(templates.contains)
          .toSet(),
      onSelectionChanged: (sel) {
        _update((c) => c.copyWith(templateId: sel.first));
      },
    );
  }

  Widget _field({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
