import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/models/category_model.dart';

class CategoryRepository {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.getCategories));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }
}
