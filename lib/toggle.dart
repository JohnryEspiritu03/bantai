import 'package:flutter/material.dart';
import 'openstreetmap.dart';
import 'evacuationmap.dart';

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
            : 'Evacuation Centers Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
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
          ? const OpenStreetMapWidget()
          : const EvacuationMapWidget(),
    );
  }
}
