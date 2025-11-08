import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarthquakeMapWidget extends StatefulWidget {
  const EarthquakeMapWidget({super.key});

  @override
  State<EarthquakeMapWidget> createState() => _EarthquakeMapWidgetState();
}

class _EarthquakeMapWidgetState extends State<EarthquakeMapWidget> {
  final List<Marker> _markers = [];
  final PopupController _popupController = PopupController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarkersFromFirestore();
  }

  Future<void> _fetchMarkersFromFirestore() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('earthquake-data').get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final lat = double.tryParse(data['Latitude'].toString());
        final lng = double.tryParse(data['Longitude'].toString());
        final mag = double.tryParse(data['Mag'].toString()) ?? 0.0;

        if (lat != null && lng != null) {
          _markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 16,
              height: 16,
              child:  GestureDetector(
                onTap: () => _showEarthquakeDialog(data),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getGreenShade(mag),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching markers: $e');
    }

    setState(() {
      _loading = false;
    });
  }

  Color _getGreenShade(double magnitude) {
    if (magnitude < 3) return Colors.green[200]!;
    if (magnitude < 5) return Colors.green[400]!;
    if (magnitude < 7) return Colors.green[600]!;
    return Colors.green[800]!;
  }

  void _showEarthquakeDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Earthquake Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Municipality: ${data['Municipality'] ?? 'Unknown'}"),
            Text("Province: ${data['Province'] ?? 'Unknown'}"),
            Text("Magnitude: ${data['Mag'] ?? '-'}"),
            Text("Date: ${data['Date'] ?? 'N/A'}"),
            Text("Time: ${data['Time'] ?? 'N/A'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _openFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenMap(markers: _markers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double containerHeight = 200;

    return GestureDetector(
      onTap: _openFullScreenMap,
      child: Container(
        height: containerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(12.881959, 121.766541),
              initialZoom: 6,
              minZoom: 5,
              maxZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.bantai.flutter_map',
              ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: _markers,
                  popupController: _popupController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fullscreen map page
class FullScreenMap extends StatelessWidget {
  final List<Marker> markers;
  const FullScreenMap({super.key, required this.markers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earthquake Map")),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(12.881959, 121.766541),
          initialZoom: 6,
          minZoom: 5,
          maxZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.bantai.flutter_map',
          ),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              markers: markers,
              popupController: PopupController(),
            ),
          ),
        ],
      ),
    );
  }
}