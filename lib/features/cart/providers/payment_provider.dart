import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_card.dart';

import '../../../core/patterns/payment_strategy.dart';

enum PaymentMethodType { cash, card, idram }

class PaymentProvider with ChangeNotifier {
  List<PaymentCard> _cards = [];
  String? _selectedCardId;
  PaymentMethodType _selectedMethodType = PaymentMethodType.cash;

  PaymentStrategy get strategy {
    switch (_selectedMethodType) {
      case PaymentMethodType.card:
        return CardPaymentStrategy(_selectedCardId ?? '');
      case PaymentMethodType.idram:
        return IdramPaymentStrategy();
      case PaymentMethodType.cash:
      default:
        return CashPaymentStrategy();
    }
  }

  static const String _cardsKey = 'user_cards';
  static const String _methodTypeKey = 'payment_method_type';

  List<PaymentCard> get cards => [..._cards];
  String? get selectedCardId => _selectedCardId;
  PaymentMethodType get selectedMethodType => _selectedMethodType;

  PaymentProvider() {
    _loadData();
  }

  PaymentCard? get selectedCard {
    if (_selectedCardId == null || _cards.isEmpty) return null;
    try {
      return _cards.firstWhere((card) => card.id == _selectedCardId);
    } catch (_) {
      return _cards.first;
    }
  }

  void setMethodType(PaymentMethodType type) async {
    _selectedMethodType = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_methodTypeKey, type.name);
  }

  void selectCard(String cardId) {
    _selectedCardId = cardId;
    _selectedMethodType = PaymentMethodType.card;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Method Type
    final methodTypeName = prefs.getString(_methodTypeKey);
    if (methodTypeName != null) {
      _selectedMethodType = PaymentMethodType.values.firstWhere(
        (e) => e.name == methodTypeName,
        orElse: () => PaymentMethodType.cash,
      );
    }

    // Load Cards
    if (prefs.containsKey(_cardsKey)) {
      final List<dynamic> cardData = json.decode(prefs.getString(_cardsKey)!);
      _cards = cardData.map((item) => PaymentCard.fromJson(item)).toList();
      if (_cards.isNotEmpty) {
        _selectedCardId = _cards.first.id;
      }
    }

    notifyListeners();
  }

  Future<void> addCard(PaymentCard card) async {
    _cards.add(card);
    _selectedCardId = card.id;
    _selectedMethodType = PaymentMethodType.card;
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
    if (_selectedCardId == cardId) {
      _selectedCardId = _cards.isNotEmpty ? _cards.first.id : null;
      if (_cards.isEmpty) _selectedMethodType = PaymentMethodType.cash;
    }
    await _saveCards();
    notifyListeners();
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardData = json.encode(_cards.map((card) => card.toJson()).toList());
    await prefs.setString(_cardsKey, cardData);
  }
}
