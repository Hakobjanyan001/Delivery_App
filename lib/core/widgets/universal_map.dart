import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;

class UniversalMap extends StatelessWidget {
  final google.LatLng initialPosition;
  final Function(google.LatLng)? onTap;
  final Set<google.Marker> googleMarkers;
  final List<osm.Marker> osmMarkers;
  final bool isReadOnly;
  final double initialZoom;
  final Function(google.GoogleMapController)? onMapCreated;
  final bool myLocationEnabled;

  const UniversalMap({
    super.key,
    required this.initialPosition,
    this.onTap,
    this.googleMarkers = const {},
    this.osmMarkers = const [],
    this.isReadOnly = false,
    this.initialZoom = 15.0,
    this.onMapCreated,
    this.myLocationEnabled = false,
  });

  bool get _isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  @override
  Widget build(BuildContext context) {
    if (_isLinux) {
      return osm.FlutterMap(
        options: osm.MapOptions(
          initialCenter: latlong.LatLng(initialPosition.latitude, initialPosition.longitude),
          initialZoom: initialZoom,
          onTap: onTap != null ? (tapPos, point) => onTap!(google.LatLng(point.latitude, point.longitude)) : null,
        ),
        children: [
          osm.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.masoor.app',
          ),
          if (osmMarkers.isNotEmpty) osm.MarkerLayer(markers: osmMarkers),
        ],
      );
    }

    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(
        target: initialPosition,
        zoom: initialZoom,
      ),
      onMapCreated: onMapCreated,
      onTap: onTap,
      markers: googleMarkers,
      myLocationEnabled: myLocationEnabled,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      scrollGesturesEnabled: !isReadOnly,
      rotateGesturesEnabled: !isReadOnly,
      tiltGesturesEnabled: !isReadOnly,
      zoomGesturesEnabled: !isReadOnly,
    );
  }
}
