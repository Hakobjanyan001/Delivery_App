import 'package:flutter/material.dart';

abstract class PaymentStrategy {
  String get name;
  IconData get icon;
  String get displayName;
  Future<bool> processPayment(double amount);
}

class CashPaymentStrategy implements PaymentStrategy {
  @override
  String get name => 'cash';
  @override
  IconData get icon => Icons.payments_outlined;
  @override
  String get displayName => 'Կանխիկ';

  @override
  Future<bool> processPayment(double amount) async {
    // Cash payment is always successful initially
    return true;
  }
}

class CardPaymentStrategy implements PaymentStrategy {
  final String cardId;
  CardPaymentStrategy(this.cardId);

  @override
  String get name => 'card';
  @override
  IconData get icon => Icons.credit_card_outlined;
  @override
  String get displayName => 'Քարտ';

  @override
  Future<bool> processPayment(double amount) async {
    // Logic for card processing via API
    return true;
  }
}

class IdramPaymentStrategy implements PaymentStrategy {
  @override
  String get name => 'idram';
  @override
  IconData get icon => Icons.account_balance_wallet_outlined;
  @override
  String get displayName => 'iDram';

  @override
  Future<bool> processPayment(double amount) async {
    // Logic for iDram redirection/processing
    return true;
  }
}
