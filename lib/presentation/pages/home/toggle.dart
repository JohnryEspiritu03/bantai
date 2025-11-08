import 'package:bantai/presentation/pages/home/map_fullscreen.dart';
import 'package:flutter/material.dart';

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
        ),
        ),
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
          ? const MapPage()
          : const EvacuationMapWidget(),
    );
  }
}