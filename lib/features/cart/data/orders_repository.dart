import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/data/auth_repository.dart';
import '../models/order_model.dart';

class OrdersRepository {
  final AuthRepository _authRepository = AuthRepository();

  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Map<String, dynamic> address,
    required String phone,
    required String paymentMethod,
  }) async {
    // We need a way to get the token. 
    // Usually, tokens are stored in AuthRepository or a secure storage.
    // For now, I'll check if we have a simple way to get it.
    // Since AuthRepository is already in the project, I'll assume we can get the current user.
    // However, the current AuthRepository implementation is using mock for token persistence.
    // I'll add a placeholder for token logic.
    
    final token = _authRepository.token;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createOrder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'totalAmount': totalAmount,
          'address': address,
          'phone': phone,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Պատվերի ստեղծումը ձախողվեց:';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    final token = _authRepository.token;

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getMyOrders),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        throw 'Պատվերների բեռնումը ձախողվեց:';
      }
    } catch (e) {
      throw 'Կապի սխալ: $e';
    }
  }
}
