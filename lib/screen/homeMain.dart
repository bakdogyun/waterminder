import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';
import '../api/userData.dart';
import 'package:moressang/notification.dart';
import 'package:moressang/ml.dart';

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
  double yesterday = 0.0;

  late Model classifier;
  late Model time;

  var _value;
  var selectedCompany;
  var listCompany;

  double nowWaterPercent = 0.0;
  double remainWaterPercent = 100.0;
  UserData? userData;
  var _type;

  List company = [];
  List companyBeverageList = [];
  List input = [
    [1],
    [0],
    [0],
    [0],
    [1],
    [1],
    [1],
    [1],
    [1],
    [1],
    [0],
    [1],
    [1],
    [0],
    [1],
    [1],
    [0],
    [1],
    [0],
    [1],
    [1],
    [1],
    [1],
    [1],
  ];

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
    context.read<WaterState>().getCompanyList();
    context.read<UserState>().getUserYesterdayRecord();
    context.read<UserState>().inferAmount();
    time = Model('time');

    _type = beverageList.first;
  }

  Future<void> getList() async {
    companyBeverageList = [];
    await context.read<WaterState>().getCompanyBeverageList(selectedCompany);
    setState(() {
      companyBeverageList = context.read<WaterState>().companyBeverageList;
      if (companyBeverageList.length > 1) {
        listCompany = companyBeverageList[0];
        companyBeverageList = companyBeverageList.sublist(1);
        print(companyBeverageList);
      } else {
        companyBeverageList = [];
      }
    });
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

  void pressTemplateBtn() {
    company = context.read<WaterState>().companyName;

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
                        '음료 검색하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 30),
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List<Widget>.generate(company.length,
                                (int index) {
                              var label = company[index];
                              return Container(
                                  padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                                  child: ChoiceChip(
                                    labelStyle: TextStyle(color: Colors.white),
                                    selectedColor: Colors.blueAccent,
                                    backgroundColor: Colors.grey,
                                    label: Text(label),
                                    selected: _value == label,
                                    onSelected: (bool selected) async {
                                      _value = label;
                                      selectedCompany = label;
                                      await getList();
                                      bottomState(() {
                                        setState() {
                                          companyBeverageList =
                                              companyBeverageList;
                                        }
                                      });
                                      print(companyBeverageList);
                                    },
                                  ));
                            }).toList()),
                      ),
                      StatefulBuilder(builder:
                          (BuildContext context, StateSetter bottomState) {
                        return Container(
                            height: 400,
                            child: ListView.separated(
                              itemCount: companyBeverageList.length,
                              itemBuilder: (context, index) {
                                print(companyBeverageList);
                                var label = companyBeverageList[index]['name'];
                                var amount =
                                    companyBeverageList[index]['amount'];
                                var type = companyBeverageList[index]['type'];
                                return GestureDetector(
                                  onTap: () async {
                                    print('hi');
                                    print(type);
                                    double temp = amount.toDouble();
                                    addWater(type, temp);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.ac_unit,
                                            size: 80,
                                            color: Colors.blueGrey,
                                          ),
                                          Text('$label',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.lightBlue)),
                                          Text('$amount',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.grey))
                                        ]),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  width: 40,
                                );
                              },
                            ));
                      }),
                      OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.red),
                            textStyle: MaterialStateProperty.all(TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16)),
                            fixedSize: MaterialStateProperty.all(Size(100, 40)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('닫기'))
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
    if (nowWater >= goalWater) {
      NotificationClass.showNotification('축하합니다!', '목표를 달성했습니다!');
    }
  }

  @override
  Widget build(BuildContext context) {
    var todayDay = DateTime.now().day;
    var todayMonth = DateTime.now().month;
    goalWater = context.watch<UserState>().userGoal.roundToDouble();
    nowWater = context.watch<UserState>().currentWater;
    nowWaterPercent = 100 * nowWater / goalWater;
    estimatedWater = context.watch<UserState>().estimatedWater.roundToDouble();

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
                            '오늘의 목표\n$goalWater ml',
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
                  Text('예측 섭취량\n$estimatedWater',
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
                            pressTemplateBtn();
                          },
                          child: Text('찾아보기')),
                      ElevatedButton(onPressed: () {}, child: Text('알람'))
                    ]))
              ],
            )),
      ],
    ));
  }
}
