import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moressang/api/userData.dart';
import 'package:moressang/api/waterData.dart';
import 'package:moressang/ml.dart';

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
  Model amountModel = new Model('amount');
  double currentWater = 0.0;
  List userWaterRecord = [];
  List userDayWaterRecord = [];
  bool isLoged = false;
  Map fiveRecord = {};
  List userAllRecord = [];
  bool isSet = false;
  double userYesterday = 0.0;
  List userYesterdayTime = [];
  double estimatedWater = 0.0;
  List estimatedTime = [];
  late int userWorkOut;
  late int userActivity;
  late int userWeight;
  double userGoal = 0.0;
  bool isReLoad = false;

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
    userWorkOut = activity;
    userWeight = weight;

    double userLbs = userWeight * 2.20462 * 0.5;
    int workOutMin = 0;
    switch (activity) {
      case 0:
        workOutMin = 10;
        break;
      case 1:
        workOutMin = 20;
        break;
      case 2:
        workOutMin = 40;
        break;
      case 3:
        workOutMin = 60;
        break;
      default:
        workOutMin = 0;
    }

    userGoal = userLbs + workOutMin / 30 * 12;
    userGoal = userGoal * 29.5735;
    print(userGoal);
    notifyListeners();
  }

  Future<void> setUserRecord() async {
    Set temp = await user.getUserTodayRecord();
    userWaterRecord = temp.toList();
    currentWater = user.currentWater;
    notifyListeners();
  }

  Future<void> setUser() async {
    List temp;
    temp = await user.getUserState();
    if (temp[0] == 'true') {
      isSet = true;
    }
    userWorkOut = int.parse(temp[1]);
    userWeight = int.parse(temp[2]);
    double userLbs = userWeight * 2.20462 * 0.5;
    int workOutMin = 0;
    switch (userWorkOut) {
      case 0:
        workOutMin = 10;
        break;
      case 1:
        workOutMin = 20;
        break;
      case 2:
        workOutMin = 40;
        break;
      case 3:
        workOutMin = 60;
        break;
      default:
        workOutMin = 0;
    }

    userGoal = userLbs + workOutMin / 30 * 12;
    userGoal = userGoal * 29.5735;
    print(userGoal);

    notifyListeners();
  }

  Future<void> getUserDayRecord(var startDay, var nextDay) async {
    Set temp = await user.getUserDayRecord(startDay, nextDay);
    userDayWaterRecord = temp.toList();
    notifyListeners();
  }

  Future<void> getUserYesterdayRecord() async {
    var temp = await user.getUserYesterdayRecord();
    userYesterday = temp[0];
    userYesterdayTime = temp[1];

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

  Future<void> inferAmount() async {
    await getUserYesterdayRecord();
    print(userYesterday);
    estimatedWater = await amountModel.inferAmount([userYesterday])[0][0];
    print(estimatedWater);
    notifyListeners();
  }

  Future<void> inferTime() async {
    await getUserYesterdayRecord();
    estimatedTime = await amountModel.inferTime(userYesterdayTime);
    print(estimatedTime);
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    await user.deleteRecord(id);
    isReLoad = true;
    notifyListeners();
  }

  Future<void> setUserGoal() async {}
}
