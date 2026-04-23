import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/business_card.dart';
import '../services/storage_service.dart';

class CardsNotifier extends StateNotifier<List<BusinessCard>> {
  CardsNotifier() : super([]) {
    _load();
  }

  static const _uuid = Uuid();

  void _load() {
    state = StorageService.instance.cardsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<BusinessCard> create({String cardName = 'Nouvelle carte'}) async {
    final card = BusinessCard(id: _uuid.v4(), cardName: cardName);
    await StorageService.instance.cardsBox.put(card.id, card);
    _load();
    return card;
  }

  Future<void> update(BusinessCard card) async {
    await StorageService.instance.cardsBox.put(card.id, card);
    _load();
  }

  Future<void> remove(String id) async {
    await StorageService.instance.cardsBox.delete(id);
    _load();
  }

  BusinessCard? byId(String id) =>
      StorageService.instance.cardsBox.get(id);
}

final cardsProvider =
    StateNotifierProvider<CardsNotifier, List<BusinessCard>>((ref) {
  return CardsNotifier();
});

final cardByIdProvider = Provider.family<BusinessCard?, String>((ref, id) {
  final cards = ref.watch(cardsProvider);
  try {
    return cards.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
