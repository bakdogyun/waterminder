import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';
import '../api/userData.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  String userName = '';
  double nowWater = 0.0;
  double goalWater = 1000.0;
  double estimatedWater = 1500.0;
  double typedWater = 0;

  double nowWaterPercent = 0.0;
  double remainWaterPercent = 100.0;
  UserData? userData;
  var _type;

  Map<String, double> waterPercent = {
    'remain': 100.0,
    'now': 0.0,
  };

  List<String> beverageList = ['water', 'coke', 'beer', 'juice'];

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    context.read<UserState>().setUserRecord();
    _type = beverageList.first;
  }

  void setType(value) {
    setState(() {
      typedWater = double.tryParse(value)!;
    });
  }

  void pressWaterBtn() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        barrierColor: Color.fromRGBO(2, 2, 2, 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 30, 15, 15),
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '직접 입력하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 30),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "섭취량 입력"),
                          onChanged: (value) {
                            bottomState(() {
                              setState(() {
                                typedWater = double.tryParse(value)!;
                              });
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        height: 30,
                      ),
                      DropdownButton(
                          value: _type,
                          items: beverageList.map((doc) {
                            print(beverageList.indexOf(doc));
                            return DropdownMenuItem(
                              value: doc,
                              child: Text(doc),
                            );
                          }).toList(),
                          onChanged: (value) {
                            bottomState(() {
                              setState(() {
                                _type = value;
                              });
                            });
                          }),
                      SizedBox(
                        width: 120,
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 16)),
                                fixedSize:
                                    MaterialStateProperty.all(Size(100, 40)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('닫기')),
                          Container(
                            width: 80,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blueAccent),
                                  textStyle: MaterialStateProperty.all(
                                      TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16)),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(100, 40))),
                              onPressed: () {
                                addWater(_type, typedWater);
                                Navigator.pop(context);
                              },
                              child: Text('추가하기'))
                        ],
                      )
                    ]),
              ),
            );
          });
        });
  }

  void addWater(String type, double water) {
    setState(() {
      context.read<UserState>().putUserRecord(type, water);
      if (nowWater <= goalWater) {
        waterPercent['now'] = nowWaterPercent;
        waterPercent['remain'] = 100 - nowWaterPercent;
      } else if (nowWater >= goalWater) {
        waterPercent['now'] = 100;
        waterPercent['remain'] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var todayDay = DateTime.now().day;
    var todayMonth = DateTime.now().month;

    nowWater = context.watch<UserState>().currentWater;
    nowWaterPercent = 100 * nowWater / goalWater;
    if (nowWater <= goalWater) {
      waterPercent['now'] = nowWaterPercent;
      waterPercent['remain'] = 100 - nowWaterPercent;
    } else if (nowWater >= goalWater) {
      waterPercent['now'] = 100;
      waterPercent['remain'] = 0;
    }
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 60,
        ),
        Expanded(
            flex: 1,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '오늘의 목표\n400ml',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 20),
                          ),
                        ],
                      ))),
              Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                    height: 50,
                    alignment: Alignment.centerRight,
                    child: Text('$todayMonth월 $todayDay일',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        )),
                  ))
            ])),
        Expanded(
            flex: 3,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('예측 섭취량\n1200ml',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.all(9.0),
                    height: 100 * 2.7,
                    width: 150,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(5)),
                    child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: nowWaterPercent * 2.7,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(2))),
                  ),
                ],
              ),
            )),
        Expanded(
            flex: 1,
            child: Center(
              child: Container(
                  child: Text(
                '지금까지 \n $nowWater ml 섭취',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              )),
            )),
        Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      ElevatedButton(
                          onPressed: () {
                            pressWaterBtn();
                          },
                          child: Text('직접입력')),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            print('hi');
                          },
                          child: Text('찾아보기'))
                    ]))
              ],
            )),
      ],
    ));
  }
}
