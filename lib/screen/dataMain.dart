import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';

class DataMain extends StatefulWidget {
  DataMain({super.key});

  @override
  State<DataMain> createState() => _DataMainState();
}

class _DataMainState extends State<DataMain> {
  var today = DateTime.now();

  var todayDate;
  var previousCurrentDay;
  var currentDate;
  var currentMonth;
  var previousNextDay;
  var nextCurrentDay;
  var nextNextDay;
  var recordList;

  void clickPrevios() async {
    previousNextDay = previousCurrentDay;
    previousCurrentDay = previousCurrentDay.subtract(Duration(days: 1));
    currentDate = previousCurrentDay.day;
    currentMonth = previousCurrentDay.month;
    await context
        .read<UserState>()
        .getUserDayRecord(previousCurrentDay, previousNextDay);
    setState(() {
      recordList = {};

      recordList = context.read<UserState>().userDayWaterRecord;
      nextNextDay = previousNextDay;
    });
  }

  void clickNext() async {
    recordList = {};
    nextCurrentDay = nextNextDay;
    nextNextDay = nextCurrentDay.add(Duration(days: 1));
    currentDate = nextCurrentDay.day;
    currentMonth = nextCurrentDay.month;
    await context
        .read<UserState>()
        .getUserDayRecord(nextCurrentDay, nextNextDay);
    setState(() {
      recordList = context.read<UserState>().userDayWaterRecord;
      previousCurrentDay = nextCurrentDay;
    });
  }

  @override
  initState() {
    super.initState();
    todayDate = today.subtract(Duration(
        hours: today.hour,
        minutes: today.minute,
        seconds: today.second,
        microseconds: today.microsecond,
        milliseconds: today.millisecond));
    previousCurrentDay = todayDate;
    nextCurrentDay = todayDate;
    currentDate = previousCurrentDay.day;
    currentMonth = previousCurrentDay.month;
    nextNextDay = previousCurrentDay.add(Duration(days: 1));
    recordList = context.read<UserState>().userWaterRecord;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.blueAccent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    clickPrevios();
                  },
                  icon: Icon(Icons.arrow_circle_left)),
              Column(
                children: [
                  Text(
                    '수분 섭취기록',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    '$currentMonth월 $currentDate일',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  )
                ],
              ),
              IconButton(
                  onPressed: () {
                    clickNext();
                  },
                  icon: Icon(Icons.arrow_circle_right))
            ],
          ),
          bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: '일별'),
              ]),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
                itemCount: recordList.length,
                itemBuilder: (context, index) {
                  if (recordList != null) {
                    var item = recordList[index];
                    return waterList(
                        type: item['type'],
                        amount: item['amount'].toString(),
                        time: item['date']);
                  }
                }),
          ],
        ),
      ),
    );
  }

  GestureDetector waterList(
      {required String type, required String amount, required Timestamp time}) {
    DateTime times = time.toDate();
    var hour = times.hour;
    var minute = times.minute;
    return GestureDetector(
      onTap: () {
        print('hi');
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            height: 100,
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Icon(
                      Icons.water_drop_outlined,
                      size: 40,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '$type',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                          child: Text(
                            '$amount ml',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          height: 20),
                    ],
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 20, 5),
                      height: 60,
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '$hour:$minute',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey),
                      ),
                    ),
                  )
                ]),
          )
        ],
      ),
    );
  }
}
