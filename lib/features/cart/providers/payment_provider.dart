import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_card.dart';

class PaymentProvider with ChangeNotifier {
  List<PaymentCard> _cards = [];
  String? _selectedCardId;

  List<PaymentCard> get cards => [..._cards];
  String? get selectedCardId => _selectedCardId;

  PaymentProvider() {
    _loadCards();
  }

  PaymentCard? get selectedCard {
    if (_selectedCardId == null) return null;
    return _cards.firstWhere((card) => card.id == _selectedCardId, orElse: () => _cards.first);
  }

  void selectCard(String cardId) {
    _selectedCardId = cardId;
    notifyListeners();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_cards')) return;
    
    final List<dynamic> cardData = json.decode(prefs.getString('user_cards')!);
    _cards = cardData.map((item) => PaymentCard.fromJson(item)).toList();
    if (_cards.isNotEmpty) {
      _selectedCardId = _cards.first.id;
    }
    notifyListeners();
  }

  Future<void> addCard(PaymentCard card) async {
    _cards.add(card);
    _selectedCardId = card.id;
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
    if (_selectedCardId == cardId) {
      _selectedCardId = _cards.isNotEmpty ? _cards.first.id : null;
    }
    await _saveCards();
    notifyListeners();
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardData = json.encode(_cards.map((card) => card.toJson()).toList());
    await prefs.setString('user_cards', cardData);
  }
}
