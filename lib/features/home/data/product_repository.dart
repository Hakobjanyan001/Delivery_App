import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/models/product_model.dart';

class ProductRepository {
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? subcategoryId,
    String? restaurantId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (subcategoryId != null) queryParams['subcategoryId'] = subcategoryId;
      if (restaurantId != null) queryParams['restaurantId'] = restaurantId;

      final uri = Uri.parse(ApiConstants.getProducts).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(
        uri,
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final uri = Uri.parse(ApiConstants.getProductById).replace(queryParameters: {'id': id});
      final response = await http.get(
        uri,
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(jsonDecode(response.body));
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }
}
