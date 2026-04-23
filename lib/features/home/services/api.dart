import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform; // Use "show" to be specific

Future<List<dynamic>> fetchCategoryKeys() async {
  String authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ZTY1N2M1MTg3OGViNmU0MTViZTRlNSIsImlhdCI6MTc3NjcwNTc0NCwiZXhwIjoxNzc2NzA5MzQ0fQ.L69QyNz0L7wvLsiJh8ivzHqTR9Wj5I0lLVUF6R_ScZs";
  
  // 1. Fixing the Base URL logic
  String baseUrl = 'localhost';
  if (!kIsWeb && Platform.isAndroid) {
    baseUrl = '10.0.2.2'; // Required for Android Emulators
  }

  final url = Uri.parse('http://$baseUrl:3000/api/category/get-categories');

  try {
    final response = await http.get(
      url, 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // Hardcoded token
      },
    );

    if (response.statusCode == 200) {
        print(response.body);
      return json.decode(response.body) as List<dynamic>;
    } else {
      print('Server Error: ${response.statusCode} - ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
}