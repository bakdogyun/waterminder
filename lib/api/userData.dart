import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  final db = FirebaseFirestore.instance;

  User? user;
  String? userName;
  String? userID;

  UserData() {
    user = FirebaseAuth.instance.currentUser;
    userID = FirebaseAuth.instance.currentUser?.uid;
    userName = user?.displayName;
  }

  void setUserDoc() {
    db.collection('user').doc(userID).set({"name": userName});
  }

  void putWaterData(String type, double amount) {
    var today = DateTime.now().toString();
    db
        .collection('user')
        .doc(userID)
        .collection('data')
        .doc(today)
        .set({'type': type, 'amount': amount});
  }
}
