import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final double lat;
  final double lon;
  final String title;

  const MapView({
    super.key,
    required this.lat,
    required this.lon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0C2D57),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lon),
          initialZoom: 15,
        ),
        children: [
          /// 🔥 TILE FIX (ANTI BLOCK)
          TileLayer(
            urlTemplate:
                "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.physiocare.app',
          ),

          /// MARKER
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lon),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}