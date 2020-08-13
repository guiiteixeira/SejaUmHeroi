import 'package:SejaUmHeroi/pages/home.dart';
import 'package:SejaUmHeroi/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SejaUmHeroi/auth/auth.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool logged;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(Duration(seconds: 4)).then((_) async {
      FirebaseUser user = await Auth().getCurrentUser();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          if (user != null)
            return MyHomePage(title: "Seja um Herói", user: user.uid);
          return Login();
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          width: 210,
          height: 210,
          child: Image.asset("img/logo.png"),
        ),
      ),
    );
  }
}
