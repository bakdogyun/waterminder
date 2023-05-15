import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moressang/provider.dart';
import 'package:provider/provider.dart';

class SettingMain extends StatelessWidget {
  const SettingMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                context.read<UserState>().setLogOut();
              },
              child: Text('logout'))
        ],
      ),
    ));
  }
}
