import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String category = "All";
  final CollectionReference earthquakeArchive = FirebaseFirestore.instance.collection("category");
  // for all items display
  Query get filteredRecipes => FirebaseFirestore.instance.collection("earthquake-data").where('category', isEqualTo: category,);
  Query get allRecipes => FirebaseFirestore.instance.collection("sample-app");
  Query get selectedRecipes => category == "All" ? allRecipes: filteredRecipes;
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
                      headerParts(),
                      mySearchBar(),
                      // for banner
                      const BannerToExplore(),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Text(
                          "Categories",
                          style:TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quick & Easy",
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: (){
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_)=> ViewAllItems(),
                              //   ),
                              // );
                            },
                            child: Text(
                              "View all",
                              style: TextStyle(
                                color: AppColors.bannerPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],),

                    ],
                  ),
                ),
                StreamBuilder(
                  stream: selectedRecipes.snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot> snapshot){
                    if(snapshot.hasData){
                      final List<DocumentSnapshot> recipes =
                          snapshot.data ?.docs ?? [];
                      return Padding(
                        padding: const EdgeInsets.only(top: 5, left: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: recipes
                                .map((e) => FoodItemsDisplay(documentSnapshot: e))
                                .toList(),
                          ),
                        ),
                      );
                    }
                    // it means if snapshot has date then show the date
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
