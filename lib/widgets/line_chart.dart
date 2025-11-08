import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constant/app_colors.dart';

class EarthquakeLineChart extends StatefulWidget {
  const EarthquakeLineChart({super.key});

  @override
  State<EarthquakeLineChart> createState() => _EarthquakeLineChartState();
}

class _EarthquakeLineChartState extends State<EarthquakeLineChart> {
  String selectedFilter = "Overall";

  final Map<String, List<FlSpot>> datasets = {
    "Overall": [
      FlSpot(2019, 300),
      FlSpot(2020, 450),
      FlSpot(2021, 380),
      FlSpot(2022, 500),
      FlSpot(2023, 420),
      FlSpot(2024, 600),
    ],
    "Per Year": [
      FlSpot(1, 40),
      FlSpot(2, 60),
      FlSpot(3, 55),
      FlSpot(4, 70),
      FlSpot(5, 90),
      FlSpot(6, 85),
    ],
    "Per Region": [
      FlSpot(1, 150),
      FlSpot(2, 250),
      FlSpot(3, 180),
      FlSpot(4, 220),
      FlSpot(5, 150),
      FlSpot(6, 230),
      FlSpot(7, 190),
      FlSpot(8, 210),
      FlSpot(9, 180),
      FlSpot(10, 240),
      FlSpot(11, 260),
      FlSpot(12, 200),
      FlSpot(13, 190),
      FlSpot(14, 180),
      FlSpot(15, 160),
      FlSpot(16, 150),
      FlSpot(17, 140),
    ],
    "Per Day": [
      FlSpot(1, 5),
      FlSpot(2, 5),
      FlSpot(3, 7),
      FlSpot(4, 6),
      FlSpot(5, 9),
      FlSpot(6, 12),
      FlSpot(7, 11),
    ],
  };

  final List<String> regions = [
    "NCR", "1", "2", "CAR", "3", "4A", "4B",
    "5", "6", "7", "8", "9",
    "10", "11", "12", "13", "BARMM"
  ];

  @override
  Widget build(BuildContext context) {
    final data = datasets[selectedFilter]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: const Text(
                      "Earthquake Statistics",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedFilter,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    items: ["Overall", "Per Year", "Per Region", "Per Day"]
                        .map(
                          (filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Line Chart
              SizedBox(
                width: chartWidth,
                height: 200,
                child: LineChart(
                  LineChartData(
                    minX: data.first.x,
                    maxX: data.last.x,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: true,
                        color: AppColors.bannerPrimary,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.bannerPrimary.withOpacity(0.2),
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            switch (selectedFilter) {
                              case "Overall":
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                  ),
                                );
                              case "Per Year":
                                return Text(
                                  "Q${value.toInt()}",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                  ),
                                );
                              case "Per Region":
                                if (value.toInt() > 0 &&
                                    value.toInt() <= regions.length) {
                                  return Text(
                                    regions[value.toInt() - 1],
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 8,
                                    ),
                                  );
                                }
                                return const Text('');
                              case "Per Day":
                                return Text(
                                  "D${value.toInt()}",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                  ),
                                );
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 50,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
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