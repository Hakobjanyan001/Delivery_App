import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/data/auth_repository.dart';
import '../models/order_model.dart';

class OrdersRepository {
  static final OrdersRepository _instance = OrdersRepository._internal();
  factory OrdersRepository() => _instance;
  OrdersRepository._internal();

  final AuthRepository _authRepository = AuthRepository();

  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Map<String, dynamic> address,
    required String phone,
    required String paymentMethod,
    String? addressId,
    double deliveryPrice = 0.0,
  }) async {
    final token = _authRepository.token;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createOrder),
        headers: ApiConstants.getHeaders(token),
        body: jsonEncode({
          'items': items,
          'totalAmount': totalAmount,
          'deliveryPrice': deliveryPrice,
          'address': address,
          if (addressId != null) 'addressId': addressId,
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
        headers: ApiConstants.getHeaders(token),
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
