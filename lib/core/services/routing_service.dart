import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class RoutingService {
  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Returns distance in kilometers between two points using real road paths.
  static Future<double> getRoadDistance(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false&alternatives=false',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          // OSRM returns distance in meters
          final double distanceInMeters = data['routes'][0]['distance'].toDouble();
          return distanceInMeters / 1000.0;
        }
      }
    } catch (e) {
      debugPrint('OSRM Routing Error: $e');
    }

    // Fallback to straight-line (Haversine) distance if API fails
    return _calculateHaversineDistance(start, end);
  }

  static double _calculateHaversineDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    final double meters = distance.as(LengthUnit.Meter, start, end);
    return meters / 1000.0;
  }
}
