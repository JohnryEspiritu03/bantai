import 'package:bantai/core/constant/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getMonthlyReportSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.bannerPrimary,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.bannerPrimary,
            ),
            child: const Center(
              child: Text(
                "Error loading data",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.bannerPrimary,
            ),
            child: const Center(
              child: Text(
                "No reports found this month",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final totalReports = data['totalReports'] ?? 0;
        final statusCounts = data['statusCounts'] as Map<String, int>? ?? {};

        return Container(
          width: double.infinity,
          height: 190,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.bannerPrimary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
            "Monthly Earthquake\nReport Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
            Text(
              "Reports since ${DateTime.now().month}/${DateTime.now().year}: $totalReports",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6, // horizontal spacing between chips
                    runSpacing: 6, // vertical spacing
                    children: statusCounts.entries.map((entry) {
                      final status = entry.key;
                      final count = entry.value;
                      return Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white, width: 1.2),
                        ),
                        label: Text(
                          "$status: $count",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<Map<String, dynamic>> getMonthlyReportSummary() async {
  final now = DateTime.now();
  final firstDayOfMonth = DateTime(now.year, now.month, 1);

  try {
    final collection = FirebaseFirestore.instance.collection('reports');
    final querySnapshot = await collection
        .where('Timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .get();

    int totalReports = querySnapshot.size;
    Map<String, int> statusCounts = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final status = data['Status'] ?? 'Unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return {
      'totalReports': totalReports,
      'statusCounts': statusCounts,
    };
  } catch (e) {
    print("Error fetching summary: $e");
    return {};
  }
}