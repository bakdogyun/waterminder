import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moressang/api/userData.dart';

class UserState with ChangeNotifier {
  UserData user = new UserData();
  double currentWater = 0.0;
  List userWaterRecord = [];
  List userDayWaterRecord = [];
  bool isLoged = false;

  Future<void> putUserRecord(String type, double amount) async {
    await user.putWaterData(type, amount);
    Set temp = await user.getUserTodayRecord();
    userWaterRecord = temp.toList();
    currentWater = user.currentWater;
    notifyListeners();
  }

  Future<void> setUserRecord() async {
    Set temp = await user.getUserTodayRecord();
    userWaterRecord = temp.toList();
    currentWater = user.currentWater;
    notifyListeners();
  }

  Future<void> getUserDayRecord(var startDay, var nextDay) async {
    Set temp = await user.getUserDayRecord(startDay, nextDay);
    userDayWaterRecord = temp.toList();
    notifyListeners();
  }

  Future<void> setLogIn() async {
    await FirebaseAuth.instance
        .authStateChanges()
        .listen((User? userAuth) async {
      if (userAuth == null) {
      } else {
        print('hi');
        await user.setUserDoc();
        isLoged = true;
        user = new UserData();
        notifyListeners();
      }
    });
  }

  Future<void> setLogOut() async {
    FirebaseAuth.instance.signOut();
    isLoged = false;
    notifyListeners();
  }
}
