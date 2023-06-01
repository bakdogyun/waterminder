import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';

class SetUser extends StatefulWidget {
  const SetUser({super.key});

  @override
  State<SetUser> createState() => _SetUserState();
}

class _SetUserState extends State<SetUser> {
  var gender = 'male';
  var activity = 0;
  var weight = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Text('정확한 예측을 위한 정보를 수집합니다',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
            child: Text('당신의 성별은?',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
          ),
          SizedBox(
            width: 200,
            child: DropdownButton(
                value: gender,
                items: [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('남성'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('여성'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                }),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
            child: Text('평소의 활동 수준은?',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
          ),
          SizedBox(
            child: DropdownButton(
                value: activity,
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('움직임이 적음'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('가벼운 활동 : 매일 20분 이상의 운동'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('활동적임 : 매일 40분 이상의 운동'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('매우 활동적임 : 매일 1시간 이상의 운동'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    activity = value!;
                  });
                }),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
            child: Text('당신의 몸무게는?',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
          ),
          Container(
            width: 300,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  weight = int.tryParse(value)!;
                });
              },
            ),
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  context
                      .read<UserState>()
                      .setUserState(gender, activity, weight);
                });
              },
              child: Text('제출하기')),
          Text('제출 시 개인정보 사용에 동의하는 것으로 간주합니다.',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10))
        ],
      ),
    );
  }
}
