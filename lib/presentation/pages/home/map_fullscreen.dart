import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constant/app_colors.dart';

class MapTogglePage extends StatefulWidget {
  const MapTogglePage({super.key});

  @override
  State<MapTogglePage> createState() => _MapTogglePageState();
}

class _MapTogglePageState extends State<MapTogglePage> {
  bool _showEarthquake = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showEarthquake
            ? 'Earthquake Map'
            : 'Evacuation Centers Map', style: TextStyle(
          color: AppColors.bannerPrimary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          fontSize: 15,
        ),),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.arrow_swap_horizontal4),
            tooltip: 'Toggle Map',
            onPressed: () {
              setState(() {
                _showEarthquake = !_showEarthquake;
              });
            },
          ),
        ],
      ),
      body: _showEarthquake
          ? const MapPage()
          : const EvacuationMapWidget(),
    );
  }
}

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
                    color: AppColors.primary,
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
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Municipality: ${data['Municipality'] ?? 'Unknown'}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),),
                            Text("Province: ${data['Province'] ?? 'Unknown'}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text("Magnitude: ${data['Mag'] ?? '-'}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text("Date: ${data['Date'] ?? 'N/A'}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text("Time: ${data['Time'] ?? 'N/A'}",
                              style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text("Radius: ${data['Radius'] ?? 'N/A'}",
                              style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Close", style: TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.normal ,
                            ),
                            ),
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

    if (mag < 3.0) return Colors.green[200]!;
    if (mag < 5.0) return Colors.green[400]!;
    if (mag < 7.0) return Colors.green[600]!;
    return Colors.green[800]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Location: $location",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Magnitude: $mag",
                            style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),),
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
        backgroundColor: AppColors.primary,
        onPressed: () async {
          setState(() {
            _markers.clear();
            _loading = true;
          });
          await _fetchMarkersFromFirestore();
        },
        child: const Icon(Icons.refresh, color: AppColors.background),
      ),
    );
  }
}