import 'package:bantai/core/constant/app_colors.dart';
import 'package:bantai/presentation/pages/archive/archive_page.dart';
import 'package:bantai/presentation/pages/guides/guides_page.dart';
import 'package:bantai/presentation/pages/report/ReportPage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'presentation/pages/home/home_page.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
      const MyAppHomeScreen(),
      const ArchivePage(),
      const ReportPage(),
      const GuidesPage(),
    ];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconSize: 26,
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.home : Iconsax.home5,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 32,
              child: Center(
                child: Icon(
                  selectedIndex == 1 ? Iconsax.archive : Iconsax.archive,
                ),
              ),
            ),
            label: "Archive",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 28,
              child: Center(
                child: Icon(
                  selectedIndex == 2 ? Iconsax.note : Iconsax.note,
                ),
              ),
            ),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.settings : Iconsax.setting_2,
            ),
            label: "Guides",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }
  navBarPage(iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: AppColors.textPrimary,
      ),
    );
  }
}
