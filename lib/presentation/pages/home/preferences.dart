import 'package:bantai/presentation/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app.dart';
import '../../../core/constant/app_colors.dart';
import '../../../widgets/my_icon_button.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // Preferences state
  bool allowNotifications = false;
  String locationScope = 'National';
  List<String> selectedRegions = [];
  List<String> selectedProvinces = [];
  double minMagnitude = 4.0;

  final List<String> locationOptions = ['National', 'Specific Regions', 'Specific Provinces'];

  // Example regions and provinces
  final List<String> regions = ['Region 1', 'Region 2', 'Region 3'];
  final List<String> provinces = ['Province A', 'Province B', 'Province C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  MyIconButton(
                    icon: Iconsax.tag_cross,
                    pressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppMainScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Preferences",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Allow Notifications
              buildPreferenceCard(
                title: "Allow Notifications",
                desc: "Toggle to receive notifications",
                icon: Iconsax.notification,
                value: allowNotifications,
                onChanged: (val) {
                  setState(() {
                    allowNotifications = val;
                  });
                },
              ),

              // Location preference
              buildPreferenceCard(
                title: "Location",
                desc: "Select where you want to receive notifications",
                icon: Iconsax.location,
                value: allowNotifications,
                enabled: allowNotifications,
                child: allowNotifications
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: locationScope,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: locationOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          locationScope = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    if (locationScope == 'Specific Regions')
                      Wrap(
                        spacing: 10,
                        children: regions.map((r) {
                          final selected = selectedRegions.contains(r);
                          return FilterChip(
                            label: Text(r, style: const TextStyle(fontFamily: 'Poppins')),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  selectedRegions.add(r);
                                } else {
                                  selectedRegions.remove(r);
                                }
                              });
                            },
                            selectedColor: Colors.green.shade200,
                          );
                        }).toList(),
                      ),
                    if (locationScope == 'Specific Provinces')
                      Wrap(
                        spacing: 10,
                        children: provinces.map((p) {
                          final selected = selectedProvinces.contains(p);
                          return FilterChip(
                            label: Text(p, style: const TextStyle(fontFamily: 'Poppins')),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  selectedProvinces.add(p);
                                } else {
                                  selectedProvinces.remove(p);
                                }
                              });
                            },
                            selectedColor: Colors.green.shade200,
                          );
                        }).toList(),
                      ),
                  ],
                )
                    : null, onChanged: (bool p1) {  },
              ),

              // Minimum Magnitude
              buildPreferenceCard(
                title: "Minimum Magnitude",
                desc: "Set the minimum magnitude of earthquakes to be notified",
                icon: Iconsax.level,
                value: allowNotifications,
                enabled: allowNotifications,
                child: allowNotifications
                    ? Column(
                  children: [
                    Slider(
                      value: minMagnitude,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      label: minMagnitude.toStringAsFixed(1),
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() {
                          minMagnitude = val;
                        });
                      },
                    ),
                    Text(
                      minMagnitude.toStringAsFixed(1),
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                    )
                  ],
                )
                    : null, onChanged: (bool p1) {  },
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Save preferences logic here
                  print({
                    'allowNotifications': allowNotifications,
                    'locationScope': locationScope,
                    'selectedRegions': selectedRegions,
                    'selectedProvinces': selectedProvinces,
                    'minMagnitude': minMagnitude,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferences saved')),
                  );
                },
                child: const Text("Save Preferences"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPreferenceCard({
    required String title,
    required String desc,
    required IconData icon,
    required bool value,
    bool enabled = true,
    Widget? child,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                    Text(desc, style: const TextStyle(fontFamily: 'Poppins')),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Checkbox(
                value: value,
                onChanged: enabled ? (bool? value) {
                  if (value != null) {
                    onChanged!(value); // Call your original onChanged if it's not null
                  }
                } : null,
                activeColor: Colors.green,
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 10),
            child,
          ]
        ],
      ),
    );
  }
}
