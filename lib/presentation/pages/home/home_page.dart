import 'package:bantai/presentation/pages/home/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/notification_services.dart';
import '../../../widgets/line_chart.dart';
import '/widgets/banner.dart';
import '/widgets/earthquake_archive_display.dart';
import '/widgets/my_icon_button.dart';
// import 'package:flutter_application_1/views/view_all_items.dart';
import '/core/constant/app_colors.dart';
import 'package:iconsax/iconsax.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

  Row headerParts(BuildContext context) {
    return Row(
      children: [
        const Text(
          "BantAI PH",
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
  final CollectionReference earthquakes =
  FirebaseFirestore.instance.collection("earthquake_data");

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
          final location = newDoc['location'] ?? 'Unknown Location';
          final magnitude = newDoc['magnitude']?.toString() ?? 'N/A';
          final date = newDoc['date'] ?? '';

          // Show notification (popup-style)
          NotificationService.showNotification(
            title: 'New Earthquake Reported!',
            body: 'Magnitude $magnitude earthquake at $location. ($date)',
          );
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

                // dashboards
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
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "View all",
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

                const EarthquakeLineChart(),
                const SizedBox(height: 25),

                const Text(
                  "Earthquake Archives",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: earthquakes.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<DocumentSnapshot> earthquakeList =
                          snapshot.data!.docs;
                      if (earthquakeList.isEmpty) {
                        return const Center(
                          child: Text(
                            "No earthquake data available.",
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: earthquakeList.length,
                        itemBuilder: (context, index) {
                          return EarthquakeArchiveDisplay(
                              documentSnapshot: earthquakeList[index]);
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
