import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class GeocodingHelper {
  static Future<String> getAddressFromCoordinates(double lat, double lon) async {
    if (kIsWeb) {
      return _getAddressFromNominatim(lat, lon);
    } else {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          return '${place.street}, ${place.locality}, ${place.country}';
        }
      } catch (e) {
        debugPrint('Mobile geocoding error: $e');
      }
      return '$lat, $lon';
    }
  }

  static Future<String> _getAddressFromNominatim(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'DeliveryApp/1.0',
          'Accept-Language': 'hy,en,ru',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayAddress = data['display_name'];
        if (displayAddress != null) {
          return displayAddress;
        }
      }
    } catch (e) {
      debugPrint('Nominatim geocoding error: $e');
    }
    return '$lat, $lon';
  }
}
