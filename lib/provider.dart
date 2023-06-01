import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moressang/api/userData.dart';
import 'package:moressang/api/waterData.dart';

class WaterState with ChangeNotifier {
  List companyName = [];
  List companyBeverageList = [];
  WaterData data = new WaterData();

  Future<void> getCompanyList() async {
    Set temp = await data.getCompanyName();
    companyName = temp.toList();
    notifyListeners();
  }

  Future<void> getCompanyBeverageList(String company) async {
    Set temp = await data.getCompanyBeverage(company);
    companyBeverageList = temp.toList();
    notifyListeners();
  }
}

class UserState with ChangeNotifier {
  UserData user = new UserData();
  double currentWater = 0.0;
  List userWaterRecord = [];
  List userDayWaterRecord = [];
  bool isLoged = false;
  Map fiveRecord = {};
  List userAllRecord = [];
  bool isSet = false;

  Future<void> putUserRecord(String type, double amount) async {
    await user.putWaterData(type, amount);
    Set temp = await user.getUserTodayRecord();
    userWaterRecord = temp.toList();
    currentWater = user.currentWater;
    notifyListeners();
  }

  Future<void> setUserState(String gender, int activity, int weight) async {
    await user.setUserState(gender, activity, weight);
    isSet = true;
    notifyListeners();
  }

  Future<void> setUserRecord() async {
    Set temp = await user.getUserTodayRecord();
    userWaterRecord = temp.toList();
    currentWater = user.currentWater;
    notifyListeners();
  }

  Future<void> setUser() async {
    isSet = await user.getUserState();
    notifyListeners();
  }

  Future<void> getUserDayRecord(var startDay, var nextDay) async {
    Set temp = await user.getUserDayRecord(startDay, nextDay);
    userDayWaterRecord = temp.toList();
    notifyListeners();
  }

  Future<void> getUserFiveRecord(var startDay, var endDay) async {
    Map temp = await user.getUserFiveRecord(startDay, endDay);
    fiveRecord = temp;
    notifyListeners();
  }

  Future<void> getUserAllRecord() async {
    Set temp = await user.getUserAllRecord();
    userAllRecord = temp.toList();
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
