import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/models/restaurant_model.dart';

class RestaurantRepository {
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getRestaurants),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RestaurantModel.fromJson(json)).toList();
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }

  Future<RestaurantModel> getRestaurantById(String id, String? token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getRestaurantById}?id=$id'),
        headers: ApiConstants.getHeaders(token),
      );

      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(jsonDecode(response.body));
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }
}
