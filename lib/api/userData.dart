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
  Set userYesterday = {};
  List userYesterdayTime = [List<int>.filled(24, 0)];
  double userYesterdayWater = 0.0;
  bool isSet = false;

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

  Future<List> getUserState() async {
    List test = [];
    await userRef.get().then((DocumentSnapshot data) async {
      final datas = data.data() as Map<String, dynamic>;
      isSet = datas['isSet'];
      String activity = datas['activity'].toString();
      String weight = datas['weight'].toString();
      test.add(isSet.toString());
      test.add(activity);
      test.add(weight);
    });

    return test;
  }

  Future<bool> setUserState(String gender, int activity, int weight) async {
    isSet = true;
    await userRef.set({
      'name': userName,
      'isSet': isSet,
      'gender': gender,
      'activity': activity,
      'weight': weight
    });

    return isSet;
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
            data['id'] = doc.id;
            userWaterRecord.add(data);
            userWaterTime.add(data['date']);
            currentWater = currentWater + data['amount'].toDouble();
          }
        },
      );
    });
    return userWaterRecord;
  }

  Future<List> getUserYesterdayRecord() async {
    var now = DateTime.now();
    var midNight = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    ));
    var yesterday = midNight.subtract(Duration(days: 1));
    userYesterday = {};
    userYesterdayWater = 0.0;
    userYesterdayTime = [List<int>.filled(24, 0)];
    await userRef
        .collection('data')
        .where('date', isLessThan: midNight)
        .where('date', isGreaterThan: yesterday)
        .orderBy('date')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach(
        (doc) {
          var data = doc.data() as Map<String, dynamic>;
          if (userWaterTime.contains(data['date'])) {
          } else {
            var hour = data['date'].toDate().hour;
            print(hour);
            userYesterdayTime[0][hour] = 1;
            userYesterday.add(data);
            userYesterdayWater = userYesterdayWater + data['amount'].toDouble();
          }
        },
      );
    });
    return [userYesterdayWater, userYesterdayTime];
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
            data['id'] = doc.id;
            userDayWaterRecord.add(data);
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
        data['id'] = doc.id;
        userAllData.add(data);
      });
    });
    return userAllData;
  }

  Future<void> deleteRecord(String id) async {
    await userRef.collection('data').doc(id).delete().then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
  }
}
