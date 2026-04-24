import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong;

class UniversalMapController {
  google.GoogleMapController? _googleController;
  osm.MapController? _osmController;

  void setGoogleController(google.GoogleMapController controller) => _googleController = controller;
  void setOsmController(osm.MapController controller) => _osmController = controller;

  Future<void> animateTo(double lat, double lng, {double zoom = 15.0}) async {
    if (_googleController != null) {
      await _googleController!.animateCamera(
        google.CameraUpdate.newLatLngZoom(google.LatLng(lat, lng), zoom),
      );
    } else if (_osmController != null) {
      _osmController!.move(latlong.LatLng(lat, lng), zoom);
    }
  }

  void setMapStyle(String style) {
    _googleController?.setMapStyle(style);
  }
}

class UniversalMap extends StatefulWidget {
  final google.LatLng initialPosition;
  final Function(google.LatLng)? onTap;
  final Set<google.Marker> googleMarkers;
  final List<osm.Marker> osmMarkers;
  final bool isReadOnly;
  final double initialZoom;
  final Function(UniversalMapController)? onMapCreated;
  final bool myLocationEnabled;
  final bool forceOSM;

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
    this.forceOSM = true,
  });

  @override
  State<UniversalMap> createState() => _UniversalMapState();
}

class _UniversalMapState extends State<UniversalMap> {
  final UniversalMapController _controller = UniversalMapController();
  final osm.MapController _osmMapController = osm.MapController();

  @override
  void initState() {
    super.initState();
    _controller.setOsmController(_osmMapController);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forceOSM) {
      return osm.FlutterMap(
        mapController: _osmMapController,
        options: osm.MapOptions(
          initialCenter: latlong.LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude),
          initialZoom: widget.initialZoom,
          onTap: widget.onTap != null ? (tapPos, point) => widget.onTap!(google.LatLng(point.latitude, point.longitude)) : null,
          onMapReady: () {
            if (widget.onMapCreated != null) {
              widget.onMapCreated!(_controller);
            }
          },
        ),
        children: [
          osm.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.masoor.app',
          ),
          if (widget.osmMarkers.isNotEmpty) osm.MarkerLayer(markers: widget.osmMarkers),
        ],
      );
    }

    return google.GoogleMap(
      initialCameraPosition: google.CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      onMapCreated: (controller) {
        _controller.setGoogleController(controller);
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(_controller);
        }
      },
      onTap: widget.onTap,
      markers: widget.googleMarkers,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      scrollGesturesEnabled: !widget.isReadOnly,
      rotateGesturesEnabled: !widget.isReadOnly,
      tiltGesturesEnabled: !widget.isReadOnly,
      zoomGesturesEnabled: !widget.isReadOnly,
    );
  }
}
