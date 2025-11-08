import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore + OpenStreetMap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Marker> _markers = [];
  bool _loading = true;

  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _fetchMarkersFromFirestore();
  }

  /// Compute green shade based on magnitude
  Color _getColorByMagnitude(double mag) {
    final intensity = (mag.clamp(0, 10) / 10);
    return Color.lerp(Colors.green[200], Colors.green[900], intensity)!;
  }

  Future<void> _fetchMarkersFromFirestore() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('earthquake-data').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final lat = double.tryParse(data['Latitude'].toString());
        final lng = double.tryParse(data['Longitude'].toString());
        final municipality = data['Municipality'] ?? 'Unknown';
        final province = data['Province'] ?? 'Unknown';
        final date = data['Date'] ?? 'Unknown';
        final time = data['Time'] ?? 'Unknown';
        final mag = double.tryParse(data['Mag'].toString()) ?? 0.0;

        if (lat != null && lng != null) {
          final color = _getColorByMagnitude(mag);

          _markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 14,
              height: 14,
              child: GestureDetector(
                onTap: () {
                  // Show popup in the center of the screen
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white,
                        title: const Text(
                          'Earthquake Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                            Text("Radius: ${data['Radius'] ?? 'N/A'}"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _getGreenShade(data['Mag']),
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
      debugPrint('Error fetching data: $e');
    }

    setState(() => _loading = false);
  }

  Color _getGreenShade(dynamic magnitude) {
    if (magnitude == null) return Colors.green[200]!;

    final mag = double.tryParse(magnitude.toString()) ?? 0.0;

    if (mag < 3.0) return Colors.green[200]!;  // light green
    if (mag < 5.0) return Colors.green[400]!;  // medium
    if (mag < 7.0) return Colors.green[600]!;  // dark
    return Colors.green[800]!;                 // very dark for strong quakes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMap + Firestore')),
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
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),

          // Marker popups
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              markers: _markers,
              popupController: _popupController,
              popupDisplayOptions: PopupDisplayOptions(
                builder: (BuildContext context, Marker marker) {
                  final data =
                      (marker.key as ValueKey<Map<String, dynamic>>).value;

                  final location = data['location'];
                  final mag = data['mag'];

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Earthquake Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Location: $location"),
                          Text("Magnitude: $mag"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _markers.clear();
            _loading = true;
          });
          await _fetchMarkersFromFirestore();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}