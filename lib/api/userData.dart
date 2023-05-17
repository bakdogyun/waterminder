import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserData {
  final db = FirebaseFirestore.instance;

  User? user;
  String? userName;
  String? userID;
  var userRef;
  double currentWater = 0.0;
  double testWater = 0.0;
  Set userWaterRecord = {};
  Set userWaterTime = {};
  Set userDayWaterRecord = {};
  Set userDayWaterTime = {};

  UserData() {
    user = FirebaseAuth.instance.currentUser;
    userID = FirebaseAuth.instance.currentUser?.uid;
    userName = user?.displayName;
    userRef = db.collection('user').doc(userID);
  }

  Future<void> setUserDoc() async {
    await userRef.get().then((DocumentSnapshot data) async {
      final datas = data.data();
      if (datas != null) {
      } else {
        await userRef.set({"name": userName});
      }
    });
  }

  Future<void> putWaterData(String type, double amount) async {
    var today = DateTime.now();
    var todayString = DateTime.now().toString();
    await userRef
        .collection('data')
        .doc(todayString)
        .set({'type': type, 'amount': amount, 'date': today});
  }

  Future<Set> getUserTodayRecord() async {
    var now = DateTime.now();
    var midNight = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    ));
    await userRef
        .collection('data')
        .where('date', isGreaterThan: midNight)
        .orderBy('date')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach(
        (doc) {
          var data = doc.data() as Map<String, dynamic>;
          if (userWaterTime.contains(data['date'])) {
          } else {
            userWaterRecord.add(data);
            userWaterTime.add(data['date']);
            currentWater = currentWater + data['amount'].toDouble();
          }
        },
      );
    });
    return userWaterRecord;
  }

  Future<Set> getUserDayRecord(var startDay, var nextDay) async {
    userDayWaterRecord = {};
    await userRef
        .collection('data')
        .where('date', isLessThan: nextDay)
        .where('date', isGreaterThan: startDay)
        .orderBy('date')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot != null) {
        snapshot.docs.forEach(
          (doc) {
            var data = doc.data() as Map<String, dynamic>;
            userDayWaterRecord.add(data);
            print(data['date'].toDate());
            userDayWaterTime.add(data['date']);
          },
        );
      } else {
        userDayWaterRecord = {};
      }
    });
    print(userDayWaterRecord);
    return userDayWaterRecord;
  }
}
