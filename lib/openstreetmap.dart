import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OpenStreetMapWidget extends StatefulWidget {
  const OpenStreetMapWidget({super.key});

  @override
  State<OpenStreetMapWidget> createState() => _OpenStreetMapWidgetState();
}

class _OpenStreetMapWidgetState extends State<OpenStreetMapWidget> {
  final List<Marker> _allMarkers = [];
  List<Marker> _filteredMarkers = [];
  bool _loading = true;
  final PopupController _popupController = PopupController();

  String _selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('earthquake-data').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // New earthquake detected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New earthquake data added!')),
          );
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.title ?? "New Alert!")),
      );
    });

    _fetchMarkersFromFirestore();
  }

  Future<void> _fetchMarkersFromFirestore() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('earthquake-data').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lat = double.tryParse(data['Latitude'].toString());
        final lng = double.tryParse(data['Longitude'].toString());
        final mag = double.tryParse(data['Mag'].toString()) ?? 0.0;

        if (lat != null && lng != null) {
          _allMarkers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 14,
              height: 14,
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
                          'Earthquake Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Municipality: ${data['Municipality']}"),
                            Text("Province: ${data['Province']}"),
                            Text("Magnitude: ${data['Mag']}"),
                            Text("Date: ${data['Date']}"),
                            Text("Time: ${data['Time']}"),
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

      _applyFilter(); // Apply filter after loading data
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    setState(() => _loading = false);
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'Low') {
        _filteredMarkers = _allMarkers.where((m) {
          final mag = _getMarkerMagnitude(m);
          return mag < 3.0;
        }).toList();
      } else if (_selectedFilter == 'High') {
        _filteredMarkers = _allMarkers.where((m) {
          final mag = _getMarkerMagnitude(m);
          return mag >= 3.0 && mag < 7.0;
        }).toList();
      } else if (_selectedFilter == 'Very High') {
        _filteredMarkers = _allMarkers.where((m) {
          final mag = _getMarkerMagnitude(m);
          return mag >= 7.0;
        }).toList();
      } else {
        _filteredMarkers = List.from(_allMarkers);
      }
    });
  }

  // Helper to extract magnitude from marker color (for filtering)
  double _getMarkerMagnitude(Marker marker) {
    final color = (marker.child as GestureDetector)
        .child as Container; // get inner container
    final box = color.decoration as BoxDecoration;
    final shade = box.color;
    if (shade == Colors.green[200]) return 2.0;
    if (shade == Colors.green[400]) return 4.0;
    if (shade == Colors.green[600]) return 6.0;
    if (shade == Colors.green[800]) return 8.0;
    return 0.0;
  }

  Color _getGreenShade(double mag) {
    if (mag < 3.0) return Colors.green[200]!;
    if (mag < 5.0) return Colors.green[400]!;
    if (mag < 7.0) return Colors.green[600]!;
    return Colors.green[800]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Map'),
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'High', child: Text('High')),
              DropdownMenuItem(value: 'Very High', child: Text('Very High')),
            ],
            onChanged: (value) {
              if (value != null) {
                _selectedFilter = value;
                _applyFilter();
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _loading
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
          MarkerLayer(markers: _filteredMarkers),
        ],
      ),
    );
  }
}