import 'package:bantai/class/Earthquake.dart';
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
  String category = "All";
  final CollectionReference earthquakeArchive = FirebaseFirestore.instance.collection("category");
  // for all items display
  Query get filteredearthquakes => FirebaseFirestore.instance.collection("earthquake-data").where('category', isEqualTo: category,);
  Query get allEarthquakeData => FirebaseFirestore.instance.collection("earthquake-data");
  Query get selectedEarthquakes => category == "All" ? allEarthquakeData: filteredearthquakes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
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
                                        category = streamSnapshot.data!.docs[index]["name"];
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: category ==
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
                                          color: category ==
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
                          // it means if snapshot has date then show the date
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
                      // return Padding(
                      //   padding: const EdgeInsets.only(top: 5, left: 15),
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       children: earthquakes
                      //           .map((e) => EarthquakeArchiveDisplay(documentSnapshot: e))
                      //           .toList(),
                      //     ),
                      //   ),
                      // );

                      // return Padding(
                      //   padding: const EdgeInsets.only(top: 5, left: 15),
                      //   child: ListView.builder(
                      //     shrinkWrap: true,
                      //     itemCount: earthquakes.length,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       final DocumentSnapshot e = earthquakes[index];
                      //       return EarthquakeArchiveDisplay(documentSnapshot: e);
                      //     },
                      //   ),
                      // );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7, // adjust height as needed
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

                      // final List<Earthquake> items = snapshot.data!.docs.map((doc) {
                      //   return Earthquake.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                      // }).toList();
                      //
                      // // ... (Build the ListView below)
                      // return ListView.builder(
                      //     itemCount: items.length,
                      //     itemBuilder: (context, index) {
                      //       final item = items[index];
                      //       return Card(
                      //         margin: EdgeInsets.all(8.0),
                      //         child: Padding(
                      //           padding: EdgeInsets.all(16.0),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Text('ID: ${item.id}', style: TextStyle(
                      //                   fontWeight: FontWeight.bold)),
                      //               Text(item.location),
                      //               Text(item.latitude),
                      //               Text(item.longitude),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     }
                      // );

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
