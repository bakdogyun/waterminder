import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';
import 'package:moressang/api/userData.dart';
import 'dart:math';

class InsightMain extends StatefulWidget {
  const InsightMain({super.key});

  @override
  State<InsightMain> createState() => _InsightMainState();
}

class _InsightMainState extends State<InsightMain> {
  final List colorList = [
    Color(0xFF0000FF),
    Color(0xFF6495ED),
    Color(0xFF4169E1),
    Color(0xFF1E90FF),
    Color(0xFF00BFFF),
    Color(0xFF87CEEB),
    Color(0xFF87CEFA),
    Color(0xFFADD8E6),
    Color(0xFFB0C4DE),
    Color(0xFF4682B4),
    Color(0xFF6A5ACD),
    Color(0xFF7B68EE),
    Color(0xFF4169E1),
    Color(0xFF0000CD),
    Color(0xFF191970),
    Color(0xFF000080),
    Color(0xFF00008B),
    Color(0xFF0000FF),
    Color(0xFF6495ED),
    Color(0xFF4169E1)
  ];
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a)
  ];
  final List<Color> gradientColorsOpacity = [
    const Color(0xff23b6e6).withOpacity(0.3),
    const Color(0xff02d39a).withOpacity(0.3)
  ];
  var recordList = [];
  int nowHour = 0;
  var list;
  Map fiveList = {};
  List<BarChartGroupData> barList = [];
  List allRecord = [];
  List<PieChartSectionData> pieList = [];
  List<Widget> typeList = [];

  @override
  initState() {
    super.initState();
    context.read<UserState>().setUserRecord();
    recordList = context.read<UserState>().userWaterRecord;

    var now = DateTime.now();
    nowHour = now.hour.toInt() + 1;
    var midNight = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    ));
    var earlyDay = midNight.subtract(Duration(days: 5));
    context.read<UserState>().getUserFiveRecord(earlyDay, now);
    context.read<UserState>().getUserAllRecord();
    fiveList = context.read<UserState>().fiveRecord;
    allRecord = context.read<UserState>().userAllRecord;
    setBarList();
    setPieData();
    setSpotList();
  }

  var nowSpotList = [
    FlSpot(0, 0),
  ];

  void setPieData() {
    Map drinkList = {};
    allRecord.forEach((element) {
      var type = element['type'];
      print(type);
      if (drinkList[type] == null) {
        drinkList[type] = element['amount'];
      } else {
        drinkList[type] = drinkList[type] + element['amount'];
      }
    });
    int index = 0;
    drinkList.forEach((type, amount) {
      pieList.add(PieChartSectionData(
          value: amount, showTitle: false, color: colorList[index]));
      typeList.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.circle,
          color: colorList[index],
        ),
        SizedBox(
          width: 20,
        ),
        Text('$type')
      ]));
      index++;
    });
  }

  void setBarList() {
    var now = DateTime.now();
    var list = [];
    for (var i = 4; i >= 0; i--) {
      var day = now.subtract(Duration(days: i)).day;
      list.add(fiveList[day]);
    }

    var index = 1;
    list.forEach((element) {
      barList.add(BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: element.toDouble(),
            color: Colors.white,
            width: 15,
            backDrawRodData: BackgroundBarChartRodData(
                show: true, toY: 2000.0, color: Colors.white.withOpacity(0.2)))
      ]));
      index++;
    });
  }

  void setSpotList() {
    nowSpotList = [FlSpot(0, 0)];
    for (var i = 0; i < nowHour; i++) {
      nowSpotList.add(FlSpot(i.toDouble(), 0));
    }

    recordList.forEach((item) {
      var time = item['date'];
      DateTime times = time.toDate();
      var hour = times.hour;
      var temp = nowSpotList[hour - 1].y;
      temp = temp + item['amount'];
      nowSpotList[hour - 1] = FlSpot(hour.toDouble(), temp);
    });
  }

  void getNowTime() {}
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
              ),
              Text("오늘의 섭취 추세",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  )),
              Container(
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 40),
                padding: EdgeInsets.all(20),
                height: 200,
                child: LineChart(
                  LineChartData(
                      gridData:
                          FlGridData(show: false, drawVerticalLine: false),
                      minX: 0,
                      maxX: 24,
                      minY: 0,
                      maxY: 4000,
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false))),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                            barWidth: 5,
                            spots: nowSpotList,
                            dotData: FlDotData(show: false),
                            isCurved: true,
                            isStrokeCapRound: true,
                            gradient: LinearGradient(colors: gradientColors),
                            belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                    colors: gradientColorsOpacity))),
                      ]),
                  swapAnimationDuration: Duration(milliseconds: 150),
                  swapAnimationCurve: Curves.linear,
                ),
              ),
              Text("최근 5일간 섭취량",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  )),
              Container(
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 40),
                padding: EdgeInsets.all(15),
                height: 200,
                child: BarChart(
                  BarChartData(
                      gridData:
                          FlGridData(show: false, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: getTitles,
                                reservedSize: 35),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false))),
                      borderData: FlBorderData(show: false),
                      barGroups: barList),
                  swapAnimationDuration: Duration(milliseconds: 150),
                  swapAnimationCurve: Curves.linear,
                ),
              ),
              Text("섭취 음료 비율",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  )),
              Container(
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                padding: EdgeInsets.all(15),
                height: 350,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [],
                    ),
                    Container(
                      width: 300,
                      height: 300,
                      child: PieChart(
                        PieChartData(
                            borderData: FlBorderData(show: false),
                            startDegreeOffset: 270,
                            centerSpaceRadius: 90,
                            sections: pieList),
                        swapAnimationDuration: Duration(milliseconds: 150),
                        swapAnimationCurve: Curves.linear,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                padding: EdgeInsets.all(15),
                child: Column(children: typeList),
              )
            ]),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w500,
      fontSize: 17,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('5일전', style: style);
        break;
      case 1:
        text = const Text('4일전', style: style);
        break;
      case 2:
        text = const Text('3일전', style: style);
        break;
      case 3:
        text = const Text('2일전', style: style);
        break;
      case 4:
        text = const Text('1일전', style: style);
        break;
      case 5:
        text = const Text('오늘',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ));
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
}
