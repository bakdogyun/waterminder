import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';

class DataMain extends StatelessWidget {
  DataMain({super.key});
  var todayDay = DateTime.now().day;
  var todayMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.blueAccent,
          title: Column(
            children: [
              Text(
                '수분 섭취기록',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              Text(
                '$todayMonth월 $todayDay일',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              )
            ],
          ),
          bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: '일별'),
                Tab(text: '주별'),
                Tab(text: '월별'),
              ]),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
                itemCount: context.watch<UserState>().userWaterRecord.length,
                itemBuilder: (context, index) {
                  var item = context.watch<UserState>().userWaterRecord[index];
                  return waterList(
                      type: item['type'],
                      amount: item['amount'].toString(),
                      time: item['date']);
                }),
            Center(child: Text('gaha')),
            Center(child: Text('gaha')),
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
