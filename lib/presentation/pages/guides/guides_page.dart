import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constant/app_colors.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {


  // toolkits
  List<Map<String, dynamic>> toolkits = [
    {"name": "First Aid Kit", "icon": Iconsax.home, "checked": false},
    {"name": "Emergency Bag", "icon": Iconsax.briefcase, "checked": false},
    {"name": "Evacuation Plan", "icon": Iconsax.map, "checked": false},
    {"name": "Evacuation Plan", "icon": Iconsax.map, "checked": false},
  ];

  double get overallProgress {
    int checkedCount = toolkits.where((t) => t['checked']).length;
    return checkedCount / toolkits.length;
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
                          // safety guides
                          const Text(
                            "Earthquake Safety Guides",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildSafetyGuides(),

                          const SizedBox(height: 25),

                          //tool kits
                          const Text(
                            "Preparedness Tool Kits",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildToolKits(),

                          const SizedBox(height: 25),

                          //safety level
                          buildGamificationProgress(),
                          const SizedBox(height: 40),
                          ]
                    ),
                ),
            ),
        ),
    );
  }


  Widget buildSafetyGuides() {
    final List<Map<String, dynamic>> guides = [
      {
        "title": "Before an Earthquake",
        "desc": "Secure furniture, prepare emergency kits, and ensure safety measures at home.",
        "icon": Iconsax.box,
        "color": Colors.greenAccent.shade100
      },
      {
        "title": "During an Earthquake",
        "desc": "Drop, cover, and hold on under sturdy furniture, avoid windows and hanging objects.",
        "icon": Iconsax.shield_cross,
        "color": Colors.lightGreen.shade100
      },
      {
        "title": "After an Earthquake",
        "desc": "Check for injuries, damages, and aftershocks. Stay alert and follow evacuation protocols.",
        "icon": Iconsax.activity,
        "color": Colors.green.shade100
      },
    ];

    return Column(
      children: guides
          .map(
            (g) => GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(g['title'],
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                content: Text(g['desc'], style: const TextStyle(fontFamily: 'Poppins')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close",
                        style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ],
              ),
            );
          },
          child: Card(
            color: g['color'],
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(g['icon'], color: AppColors.bannerPrimary),
              ),
              title: Text(
                g['title'],
                style: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Iconsax.arrow_right_3),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  //toolkits
  Widget buildToolKits() {
    return Column(
      children: toolkits
          .map(
            (t) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))
            ],
          ),
          child: Row(
            children: [
              Icon(t['icon'], color: AppColors.bannerPrimary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: t['checked'] ? 1.0 : 0.0,
                        minHeight: 6,
                        color: AppColors.bannerPrimary,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Checkbox(
                value: t['checked'],
                onChanged: (val) {
                  setState(() {
                    t['checked'] = val ?? false;
                  });
                },
                activeColor: AppColors.bannerPrimary,
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }

  // GAMIFICATION PROGRESS BASED ON TOOLKITS
  Widget buildGamificationProgress() {
    final progress = overallProgress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bannerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Safety Level",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: AppColors.bannerPrimary,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              if (i < (progress * 3).ceil()) {
                return const Icon(Iconsax.star5, color: Colors.amber, size: 20);
              } else {
                return const Icon(Iconsax.star5, color: Colors.grey, size: 20);
              }
            }),
          ),
          const SizedBox(height: 5),
          Text(
            "Complete toolkits to increase your safety level!",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

