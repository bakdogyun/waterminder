import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WaterData {
  final db = FirebaseFirestore.instance;

  Set companyName = {};
  Set companyBeverageList = {};

  User? user;
  String? userName;
  String? userID;
  var waterRef;
  double currentWater = 0.0;
  double testWater = 0.0;
  Set userWaterRecord = {};
  Set userWaterTime = {};
  Set userDayWaterRecord = {};
  Set userDayWaterTime = {};

  WaterData() {
    waterRef = db.collection('companydata');
  }

  Future<Set> getCompanyName() async {
    await waterRef.get().then((QuerySnapshot data) async {
      for (var docSnapshot in data.docs) {
        companyName.add(docSnapshot.id);
      }
    });
    return companyName;
  }

  Future<Set> getCompanyBeverage(String company) async {
    companyBeverageList = {};

    companyBeverageList.add(company);
    await waterRef
        .doc(company)
        .collection('drinkdata')
        .get()
        .then((QuerySnapshot data) async {
      for (var docSnapshot in data.docs) {
        if (docSnapshot.exists) {
          var docs = docSnapshot.data() as Map<String, dynamic>;
          print(docs['type']);
          companyBeverageList.add({
            'name': docs['name'],
            'amount': docs['amount'],
            'type': docs['type']
          });
        }
      }
      print(companyBeverageList);
      return companyBeverageList;
    });

    return companyBeverageList;
  }

  /*

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
  */
}
