import 'package:SejaUmHeroi/auth/auth.dart';
import 'package:SejaUmHeroi/pages/home.dart';
import 'package:SejaUmHeroi/pages/login.dart';
import 'package:SejaUmHeroi/resources/colors.dart';
import 'package:SejaUmHeroi/resources/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  Settings({this.title, this.user});

  final String user;
  final String title;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String username = "";
  String fontValue = "Normal";
  String themeValue = "Colorido";
  Color lprimary;
  Color lsecondary;
  double fontP;
  double fontT;
  double fontST;

  Future<void> initRealPreferences() async {
    final vprimary = await Config.instance().getPrimary();
    final vsecondary = await Config.instance().getSecondary();
    final vfontP = await Config.instance().getPFont();
    final vfontT = await Config.instance().getTFont();
    final vfontST = await Config.instance().getSTFont();

    setState(() {
      lprimary = vprimary;
      lsecondary = vsecondary;
      fontP = vfontP;
      fontT = vfontT;
      fontST = vfontST;
    });
  }

  Future<void> _showFontDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolher tamanho'),
          content: StatefulBuilder(
            builder: (context, setStateAlert) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: DropdownButton(
                        hint: Text("Selecionar"),
                        items: [
                          DropdownMenuItem(
                            child: Container(
                              child: Text("Normal"),
                              width: 200,
                            ),
                            value: "Normal",
                          ),
                          DropdownMenuItem(
                            child: Container(
                              child: Text("Aumentada"),
                              width: 200,
                            ),
                            value: "Aumentada",
                          )
                        ],
                        onChanged: (newValue) async {
                          setStateAlert(() {
                            fontValue = newValue;
                          });
                          (await SharedPreferences.getInstance())
                              .setString("font", newValue);
                        },
                        value: fontValue,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirmar'),
              onPressed: () async {
                await initRealPreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showThemeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolher tema'),
          content: StatefulBuilder(
            builder: (context, setStateAlert) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: DropdownButton(
                        hint: Text("Selecionar"),
                        items: [
                          DropdownMenuItem(
                            child: Container(
                              child: Text("Colorido"),
                              width: 200,
                            ),
                            value: "Colorido",
                          ),
                          DropdownMenuItem(
                            child: Container(
                              child: Text("Dark"),
                              width: 200,
                            ),
                            value: "Dark",
                          )
                        ],
                        onChanged: (newValue) async {
                          setStateAlert(() {
                            themeValue = newValue;
                          });
                          (await SharedPreferences.getInstance())
                              .setString("theme", newValue);
                        },
                        value: themeValue,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirmar'),
              onPressed: () async {
                await initRealPreferences();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initPreferences() async {
    String theme = (await SharedPreferences.getInstance()).getString("theme");
    String font = (await SharedPreferences.getInstance()).getString("font");

    setState(() {
      fontValue = font;
      themeValue = theme;
    });
  }

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection("user")
        .document(widget.user)
        .get()
        .then((result) {
      setState(() {
        username = result.data["name"];
      });
    });

    initPreferences();
    initRealPreferences();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
        child: Scaffold(
            appBar: PreferredSize(
                child: AppBar(
                  title: Center(
                      child: Text(
                    widget.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                preferredSize: Size.fromHeight(50)),
            body: Center(
              child: Column(
                children: [
                  Container(
                      width: screenWidth * 0.9,
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.user,
                            size: screenWidth * 0.2,
                            color: lsecondary,
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth * 0.6,
                            child: Text(
                              username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: lprimary,
                                  fontSize: fontST),
                            ),
                          )
                        ],
                      )),
                  Container(
                      width: screenWidth * 0.9,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400))),
                      child: InkWell(
                        child: Text(
                          "Alterar tamanho da fonte",
                          style: TextStyle(fontSize: fontP),
                        ),
                        onTap: _showFontDialog,
                      )),
                  Container(
                      width: screenWidth * 0.9,
                      height: 30,
                      alignment: Alignment.center,
                      child: InkWell(
                        child: Text("Alterar tema",
                            style: TextStyle(fontSize: fontP)),
                        onTap: _showThemeDialog,
                      )),
                  Container(
                      width: screenWidth * 0.9,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.grey.shade400))),
                      child: InkWell(
                        child: Text("Sair", style: TextStyle(fontSize: fontP)),
                        onTap: () {
                          Auth().signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ));
                        },
                      )),
                  Container(
                      width: 100,
                      height: 30,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: lprimary,
                      ),
                      alignment: Alignment.center,
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.home,
                              size: 20,
                              color: Colors.white,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: Text(
                                "Voltar",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontP),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(
                                  title: widget.title,
                                  user: widget.user,
                                ),
                              ));
                        },
                      )),
                ],
              ),
            )),
        onWillPop: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(
                  title: widget.title,
                  user: widget.user,
                ),
              ));
        });
  }
}
