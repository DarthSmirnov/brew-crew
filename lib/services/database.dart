import 'package:brew_crew/models/brew.dart';
import 'package:brew_crew/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  //collection reference
  final CollectionReference brewCollection = Firestore.instance.collection('brews');

  Future updateUserData(String sugar, String name, int strength) async{
    return await brewCollection.document(uid).setData({
      'sugar': sugar,
      'name':name,
      'strength':strength
    });
  }

  Future<UserData> getUserData() async{
    final snap = await brewCollection.document(uid).get();

    return _userDataFromSnapshot(snap);
  }
  // brew list from snapshot
  List<Brew> _brewListFromSnapshots(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return Brew(
        name: doc.data['name'] ?? '', 
        sugars: doc.data['sugar'] ?? '0', 
        strength: doc.data['strength'] ?? 0
      );
    }).toList();
  }

  // userdata from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    if(snapshot.data != null){
      return UserData(
        uid: uid,
        name: snapshot.data['name'],
        sugars: snapshot.data['sugar'],
        strength: snapshot.data['strength'],
      );
    }else{
      return null;
    }
  }

  // get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots().map(_brewListFromSnapshots);
  }

  // get user doc stream
  Stream<UserData> get userData {
    return brewCollection.document(uid).snapshots().map(_userDataFromSnapshot);
  }
}