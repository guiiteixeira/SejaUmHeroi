import 'package:SejaUmHeroi/auth/auth.dart';
import 'package:SejaUmHeroi/pages/home.dart';
import 'package:SejaUmHeroi/pages/register.dart';
import 'package:SejaUmHeroi/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final senha = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.8;

    void login() async {
      try {
        String user = await Auth().signIn(email.text.trim(), senha.text);
        if (user != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(title: "Seja um Herói", user: user),
              ));
        }
      } catch (e) {
        Alert(
            context: context,
            title: "Erro ao efetuar login",
            type: AlertType.error,
            desc: "Email ou senha inválidos",
            buttons: [
              DialogButton(
                color: primary,
                child: Text(
                  "Ok",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ]).show();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Center(
            child: Container(
              height: 540,
              child: Column(
                children: <Widget>[
                  Image.asset(
                    "img/logo.png",
                    height: 200,
                    width: 200,
                  ),
                  Container(
                    width: maxWidth,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      "Email",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xff0066ff),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: maxWidth,
                    child: TextField(
                      controller: email,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Digite seu email"),
                    ),
                  ),
                  Container(
                    width: maxWidth,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      "Senha",
                      style: TextStyle(
                        color: secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: maxWidth,
                    child: TextField(
                      controller: senha,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Digite sua senha"),
                    ),
                  ),
                  Container(
                    width: maxWidth,
                    margin: EdgeInsets.only(top: 15),
                    child: RaisedButton(
                      color: primary.shade900,
                      onPressed: login,
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50, bottom: 40),
                    child: InkWell(
                      child: Text(
                        "Não tenho cadastro",
                        style: TextStyle(
                          color: primary.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
