import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // TODO: Replace with your real API URL provided later
  static const String _baseUrl = 'https://api.yourbackend.com/v1';

  static Future<String?> initiatePayment({
    required double amount,
    required String currency,
    required String? cardId, // null if it's a new card
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-payment-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'card_id': cardId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['payment_url']; // The URL to open in WebView
      }
    } catch (e) {
      // For now, we return a mock URL for testing purposes
      return 'https://stripe.com/docs/payments/accept-a-payment?platform=web#3d-secure';
    }
    return null;
  }
}
