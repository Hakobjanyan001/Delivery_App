import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/models/banner_model.dart';

class BannerRepository {
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getBanners),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }

  Future<BannerModel> getBannerById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.getBannerById}?id=$id'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        return BannerModel.fromJson(jsonDecode(response.body));
      } else {
        throw 'Հարցումը ձախողվեց: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Կապի սխալ: Ստուգեք ինտերնետը: $e';
    }
  }
}
