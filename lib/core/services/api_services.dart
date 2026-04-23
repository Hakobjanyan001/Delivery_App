import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';
import '../constants/api_constants.dart';

class ApiManager {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse(ApiConstants.getRestaurants));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<List<FoodItem>> getFoods() async {
    final response = await http.get(Uri.parse(ApiConstants.getProducts));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<dynamic>> getPosts() async {
    final response = await http.get(Uri.parse(ApiConstants.getBanners));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load banners');
    }
  }
}
