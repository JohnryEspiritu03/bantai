import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart.';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier{
  List <String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List <String> get favorites => _favoriteIds;

  FavoriteProvider(){
    loadFavorites();
  }
  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    if(_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId); // remove from favorite
    } else{
      _favoriteIds.add(productId);
      await _addFavorite(productId); // add to favorite
    }
    notifyListeners();
  }
  //   check if a product is favorited
  bool isExist(DocumentSnapshot product){
    return _favoriteIds.contains(product.id);
  }
//   add favorites to Firestore
  Future <void> _addFavorite(String productId) async{
    try{
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite': true
      });
    }catch(e){
      print(e.toString());
    }
  }
  //remove favorite from firestore
  Future <void> _removeFavorite(String productId) async{
    try{
      await _firestore.collection("userFavorite").doc(productId).delete();
    }catch(e){
      print(e.toString());
    }
  }
//   load favorites from firestore
  Future <void> loadFavorites()async{
    try{
      QuerySnapshot snapshot = await _firestore.collection("userfavorite").get();
      _favoriteIds =snapshot.docs.map((doc)=> doc.id).toList();
    } catch (e){
      print(e.toString());
    }
    notifyListeners();
  }

//   Static method to access the provide from any content
  static FavoriteProvider of (BuildContext context, {bool listen = true}){
    return Provider.of<FavoriteProvider>
      (context, listen: listen,
    );
  }

}