import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../widgets/earthquake_archive_display.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String geo_area = "All";
  final CollectionReference earthquakeArchive = FirebaseFirestore.instance.collection("geographical-area");
  // for all items display
  Query get filteredEarthquakes => FirebaseFirestore.instance.collection("earthquake-data").orderBy('Date', descending: true).orderBy('Time', descending: true).where('GeoArea', isEqualTo: geo_area);
  Query get allEarthquakeData => FirebaseFirestore.instance.collection("earthquake-data").orderBy('Date', descending: true).orderBy('Time', descending: true);
  Query get selectedEarthquakes => geo_area == "All" ? allEarthquakeData: filteredEarthquakes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // for banner
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Text(
                          "Earthquake Archives",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      //   for category
                      StreamBuilder(
                        stream: earthquakeArchive.snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> streamSnapshot){
                          if(streamSnapshot.hasData){
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  streamSnapshot.data!.docs.length,
                                      (index)=>GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        geo_area = streamSnapshot.data!.docs[index]["name"];
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: geo_area ==
                                            streamSnapshot.data!.docs[index]
                                            ["name"]
                                            ? AppColors.primary
                                            : Colors.white,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical:10),
                                      margin: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        streamSnapshot.data!.docs[index]["name"],
                                        style: TextStyle(
                                          color: geo_area ==
                                              streamSnapshot.data!.docs[index]
                                              ["name"]
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                    ],
                  ),
                ),
                StreamBuilder(
                  stream: selectedEarthquakes.snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot> snapshot){
                    if(snapshot.hasData){
                      final List<DocumentSnapshot> earthquakes =
                          snapshot.data ?.docs ?? [];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 1,
                          child: ListView.builder(
                            itemCount: earthquakes.length,
                            itemBuilder: (context, index) {
                              final e = earthquakes[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: EarthquakeArchiveDisplay(documentSnapshot: e),
                              );
                            },
                          ),
                        ),
                      );

                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                )
              ],
            ),
          )
      ),
    );
  }
}
