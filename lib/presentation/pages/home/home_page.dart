import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/widgets/banner.dart';
import '/widgets/food_items_display.dart';
import '/widgets/my_icon_button.dart';
// import 'package:flutter_application_1/views/view_all_items.dart';
import '/core/constant/app_colors.dart';
import 'package:iconsax/iconsax.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  // for category
  final CollectionReference categoriesItems = FirebaseFirestore.instance.collection("category");
  // for all items display
  Query get filteredRecipes => FirebaseFirestore.instance.collection("sample-app").where('category', isEqualTo: category,);
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
                        stream: categoriesItems.snapshots(),
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

Row headerParts() {
  return Row(
    children: [
      Text(
        "BantAI.ph",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
      const Spacer(),
      MyIconButton(
        icon: Iconsax.notification,
        pressed: () {},
      ),
    ],
  );
}

Padding mySearchBar() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 22),
    child: TextField(
      decoration: InputDecoration(
        filled: true,
        prefixIcon: const Icon(Iconsax.search_normal),
        fillColor: Colors.white,
        border: InputBorder.none,
        hintText: "Search any recipes",
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}