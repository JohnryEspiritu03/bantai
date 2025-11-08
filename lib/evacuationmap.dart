import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EvacuationMapWidget extends StatefulWidget {
  const EvacuationMapWidget({super.key});

  @override
  State<EvacuationMapWidget> createState() => _EvacuationMapWidgetState();
}

class _EvacuationMapWidgetState extends State<EvacuationMapWidget> {
  final List<Marker> _markers = [];
  bool _loading = true;
  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _fetchEvacuationCenters();
  }

  Future<void> _fetchEvacuationCenters() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('evacuation-data').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lat = double.tryParse(data['Y'].toString());
        final lng = double.tryParse(data['X'].toString());
        final name = data['name'] ?? 'Unnamed Center';
        final capacity = data['capacity'] ?? 'Unknown';

        if (lat != null && lng != null) {
          _markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 16,
              height: 16,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Evacuation Center',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: $name"),
                            Text("Place: ${data['place'] ?? 'Unknown'}"),
                            Text("Municipality: ${data['municipality']}"),
                            Text("Province: ${data['province']}"),
                            Text("Type: ${data['type']}"),
                            Text("Capacity: $capacity"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
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
      debugPrint('Error fetching evacuation data: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(12.881959, 121.766541),
        initialZoom: 6,
        minZoom: 5,
        maxZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.mapapp',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }
}
