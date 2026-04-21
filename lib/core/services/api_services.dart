import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';

class ApiManager {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<List<FoodItem>> getFoods() async {
    final response = await http.get(Uri.parse('$baseUrl/foods'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  Future<List<dynamic>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
