import 'package:SejaUmHeroi/models/case.dart';
import 'package:SejaUmHeroi/resources/config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Details extends StatefulWidget {
  Details({this.title, this.user, this.casee});

  final String user;
  final String title;
  final Case casee;

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Color lprimary;
  Color lsecondary;
  double fontP;
  double fontT;
  double fontST;

  void initPreferences() async {
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

  void alertError(String error, context) {
    Alert(
        context: context,
        title: "Erro ao entrar em contato",
        type: AlertType.error,
        desc: error,
        buttons: [
          DialogButton(
            color: lprimary,
            child: Text(
              "Ok",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]).show();
  }

  @override
  void initState() {
    super.initState();

    initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Center(
                child: Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          preferredSize: Size.fromHeight(50)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth * 0.9,
              margin: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                widget.casee.title,
                style: TextStyle(
                    color: lsecondary,
                    fontSize: fontST,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.9,
                    margin: EdgeInsets.only(top: 24),
                    child: Text(
                      "ONG:",
                      style: TextStyle(
                          color: lsecondary,
                          fontSize: fontT,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.9,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      widget.casee.ong.name,
                      style: TextStyle(fontSize: fontP),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.45,
                        margin: EdgeInsets.only(top: 16),
                        child: Text(
                          "Local:",
                          style: TextStyle(
                              color: lsecondary,
                              fontSize: fontT,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.45,
                        margin: EdgeInsets.only(top: 16),
                        child: Text(
                          "Valor:",
                          style: TextStyle(
                              color: lsecondary,
                              fontSize: fontT,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.45,
                        margin: EdgeInsets.only(top: 8, bottom: 24),
                        child: Text(
                          widget.casee.ong.city +
                              " - " +
                              widget.casee.ong.state,
                          style: TextStyle(fontSize: fontP),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.45,
                        margin: EdgeInsets.only(top: 8, bottom: 24),
                        child: Text(
                          widget.casee.value.toString(),
                          style: TextStyle(fontSize: fontP),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.9,
              margin: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                "Descrição",
                style: TextStyle(
                    color: lsecondary,
                    fontSize: fontT,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Container(
                width: screenWidth * 0.9,
                margin: EdgeInsets.all(16),
                child: Text(
                  widget.casee.description,
                  style: TextStyle(fontSize: fontP),
                ),
              ),
            ),
            Container(
              width: screenWidth * 0.9,
              margin: EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                "Salve o dia!",
                style: TextStyle(
                    color: lsecondary,
                    fontSize: fontT,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Card(
                child: Column(
              children: [
                Container(
                  width: screenWidth * 0.9,
                  margin: EdgeInsets.only(top: 16),
                  child: Text(
                    "Entre em contato:",
                    style: TextStyle(fontSize: fontP),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 8, bottom: 16, right: 8),
                        width: screenWidth * 0.4,
                        child: RaisedButton(
                            color: lprimary,
                            child: Text(
                              "Email",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontP),
                            ),
                            onPressed: () async {
                              //Share.share(
                              //   'check out my website https://example.com',
                              //   subject: 'Look what I made!',);
                              final Uri _emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: widget.casee.ong.email,
                                  queryParameters: {
                                    'subject': widget.casee.title
                                  });

                              // ...

                              // mailto:smith@example.com?subject=Example+Subject+%26+Symbols+are+allowed%21
                              await launch(_emailLaunchUri.toString());
                            })),
                    Container(
                        width: screenWidth * 0.4,
                        margin: EdgeInsets.only(top: 8, bottom: 16, left: 8),
                        child: RaisedButton(
                            color: lprimary,
                            child: Text(
                              "WhatsApp",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontP),
                            ),
                            onPressed: () async {
                              var whatsappUrl = "whatsapp://send?phone=" +
                                  widget.casee.ong.whatsapp;
                              await canLaunch(whatsappUrl)
                                  ? launch(whatsappUrl)
                                  : alertError(
                                      "Whatsapp não instalado!", context);
                            })),
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
