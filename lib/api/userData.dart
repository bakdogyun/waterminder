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
  Set userAllData = {};

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
        await userRef.set({"name": userName, "isSet": false});
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

  Future<void> getUserMonthRecord() async {
    var date = DateTime.now();
    var newDate = new DateTime(date.year, date.month - 2, date.day);
    var firstMonth = newDate.subtract(Duration(days: newDate.day - 1));
    var nextMonth =
        new DateTime(firstMonth.year, firstMonth.month + 1, firstMonth.day);
    await userRef
        .collection('data')
        .where('date', isLessThan: firstMonth)
        .where('date', isGreaterThan: nextMonth)
        .orderBy('date')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        print(element);
      });
    });
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
    return userDayWaterRecord;
  }

  Future<Map> getUserFiveRecord(var startDay, var endDay) async {
    Map userFiveDay = {};
    var now = DateTime.now();

    for (var i = 0; i < 5; i++) {
      var day = now.subtract(Duration(days: i)).day;
      userFiveDay[day] = 0;
    }

    await userRef
        .collection('data')
        .where('date', isLessThan: endDay)
        .where('date', isGreaterThan: startDay)
        .orderBy('date')
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot != null) {
        snapshot.docs.forEach((doc) {
          var data = doc.data() as Map<String, dynamic>;
          var date = data['date'].toDate().day;
          var temp;
          if (userFiveDay[date] != null) {
            temp = userFiveDay[date];
          } else {
            temp = 0;
          }
          userFiveDay[date] = temp + data['amount'];
        });
      }
    });

    return userFiveDay;
  }

  Future<Set> getUserAllRecord() async {
    userAllData = {};
    await userRef
        .collection('data')
        .orderBy('date')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        userAllData.add(data);
      });
    });
    return userAllData;
  }
}
