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
    {"name": "First Aid Kit", "icon": Iconsax.briefcase, "checked": false},
    {"name": "Emergency Bag", "icon": Iconsax.briefcase, "checked": false},
    {"name": "Evacuation Plan", "icon": Iconsax.map, "checked": false},
    {"name": "Flashlight", "icon": Iconsax.lamp, "checked": false},
    {"name": "Water Supply", "icon": Iconsax.drop, "checked": false},
    {"name": "Whistle", "icon": Iconsax.notification, "checked": false},
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Safety Guides
              const Text(
                "Safety Guides",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  fontFamily: 'Poppins',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 15),
              buildSafetyGuides(),

              const SizedBox(height: 30),

              // Tool Kits
              const Text(
                "Preparedness Tool Kits",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              buildToolKits(),

              const SizedBox(height: 25),

              // Safety Level
              buildGamificationProgress(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSafetyGuides() {
    final List<Map<String, dynamic>> guides = [
      {
        "title": "Before",
        "desc": "Secure furniture and prepare emergency kits.",
        "icon": Iconsax.box,
        "color": Colors.greenAccent.shade100
      },
      {
        "title": "During",
        "desc": "Drop, cover, and hold on. Avoid windows.",
        "icon": Iconsax.shield_cross,
        "color": Colors.lightGreen.shade100
      },
      {
        "title": "After",
        "desc": "Check for injuries and damages.",
        "icon": Iconsax.activity,
        "color": Colors.green.shade100
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: guides.map((g) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    g['title'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    g['desc'],
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
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: g['color'],
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    g['icon'],
                    size: 48, // 🔹 Large icon
                    color: AppColors.bannerPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    g['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildToolKits() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: toolkits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final t = toolkits[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                t['icon'],
                color: AppColors.bannerPrimary,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t['name'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
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
        );
      },
    );
  }

  // 🪙 SAFETY LEVEL / GAMIFICATION
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
          const Text(
            "Complete toolkits to increase your safety level!",
            style: TextStyle(
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