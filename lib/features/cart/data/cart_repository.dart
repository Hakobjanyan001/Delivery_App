import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/data/auth_repository.dart';
import '../models/cart_item.dart';

class CartRepository {
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  final AuthRepository _authRepository = AuthRepository();

  Future<void> addToCart({
    required String productId,
    String? variantId,
    String? variantName,
    List<CartAttribute> attributes = const [],
    required double unitPrice,
    required int cookingTime,
    required bool is18Plus,
    required int quantity,
    String? note,
  }) async {
    final token = _authRepository.token;
    
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.addToCart),
        headers: ApiConstants.getHeaders(token),
        body: jsonEncode({
          'productId': productId,
          'variantId': variantId,
          'variantName': variantName,
          'attributes': attributes.map((a) => a.toJson()).toList(),
          'unitPrice': unitPrice,
          'cookingTime': cookingTime,
          'is18Plus': is18Plus,
          'quantity': quantity,
          'note': note,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['error'] ?? 'Ձախողվեց ավելացնել զամբյուղին:';
      }
    } catch (e) {
      throw 'Կապի սխալ: $e';
    }
  }

  Future<void> deleteFromCart({
    required String productId,
    String? variantId,
    int? quantity,
  }) async {
    final token = _authRepository.token;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.deleteFromCart),
        headers: ApiConstants.getHeaders(token),
        body: jsonEncode({
          'productId': productId,
          'variantId': variantId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['error'] ?? 'Ձախողվեց հեռացնել զամբյուղից:';
      }
    } catch (e) {
      throw 'Կապի սխալ: $e';
    }
  }

  Future<void> deleteAllFromCart() async {
    final token = _authRepository.token;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.deleteAllFromCart),
        headers: ApiConstants.getHeaders(token),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw error['error'] ?? 'Ձախողվեց դատարկել զամբյուղը:';
      }
    } catch (e) {
      throw 'Կապի սխալ: $e';
    }
  }

  Future<List<CartItem>> getCart() async {
    final token = _authRepository.token;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getCart),
        headers: ApiConstants.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null || data['items'] == null) return [];
        
        final List<dynamic> items = data['items'];
        return items.map((item) => CartItem.fromJson(item)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw error['error'] ?? 'Զամբյուղի բեռնումը ձախողվեց:';
      }
    } catch (e) {
      throw 'Կապի սխալ: $e';
    }
  }
}
