import 'package:bantai/presentation/pages/home/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../widgets/earthquake_map.dart';
import '../../../widgets/line_chart.dart';
import '/widgets/banner.dart';
import '/widgets/my_icon_button.dart';
import '/core/constant/app_colors.dart';
import 'package:iconsax/iconsax.dart';

import 'map_fullscreen.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

  Row headerParts(BuildContext context) {
    return Row(
      children: [
        const Text(
          "BantayPH",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
            fontFamily: 'Poppins',
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.settings2,
          pressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Earthquake Alert",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "A magnitude 5.9 earthquake was recorded with the epicenter in EM's Barrio East. Leagzpi City, Albay at 11:34 AM today, November 9",
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.settings,
          pressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_)=> PreferencesPage(),
              ),
            );
          },
        ),
      ],
    );
  }

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  final CollectionReference earthquakes = FirebaseFirestore.instance.collection("earthquake-data");

  Stream<QuerySnapshot>? _earthquakeStream;
  List<String> _knownDocIds = [];

  @override
  void initState() {
    super.initState();
    _earthquakeStream = earthquakes.snapshots();

    // Listen for new documents added in real-time
    _earthquakeStream!.listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added &&
            !_knownDocIds.contains(change.doc.id)) {
          _knownDocIds.add(change.doc.id);

          final newDoc = change.doc.data() as Map<String, dynamic>;
          final municipality = newDoc['Municipality'] ?? 'Unknown Location';
          final magnitude = newDoc['Mag']?.toString() ?? 'N/A';
          final date = newDoc['Date'] ?? '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                headerParts(context),
                const SizedBox(height: 15),
                const BannerToExplore(),
                const SizedBox(height: 20),

                //earthquake map
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(
                    "Interactive Map",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => MapTogglePage(),),);
                      },
                      child: Text(
                        "View",
                        style: TextStyle(
                          color: AppColors.bannerPrimary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Open full screen map
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenMapPage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: const EarthquakeMapWidget(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // DASHBOARD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        "Dashboard",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // LINE CHART
                const EarthquakeLineChart(),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// FULL SCREEN MAP PAGE
class FullScreenMapPage extends StatelessWidget {
  const FullScreenMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earthquake Map"),
      ),
      body: const EarthquakeMapWidget(),
    );
  }
}