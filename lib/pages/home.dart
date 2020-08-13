import 'dart:developer';
import 'dart:io';

import 'package:SejaUmHeroi/auth/auth.dart';
import 'package:SejaUmHeroi/models/case.dart';
import 'package:SejaUmHeroi/models/ong.dart';
import 'package:SejaUmHeroi/pages/listLiked.dart';
import 'package:SejaUmHeroi/pages/login.dart';
import 'package:SejaUmHeroi/resources/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final String user;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Case> cases = [];

  void likeAction(Case casee) async {
    final result = await Firestore.instance
        .collection("user_case_relation")
        .where("case", isEqualTo: casee.id)
        .where("user", isEqualTo: widget.user)
        .limit(1)
        .getDocuments();

    if (result.documents.length > 0) {
      final document = result.documents[0].data;
      Firestore.instance
          .collection("user_case_relation")
          .document(result.documents[0].documentID)
          .updateData({
        'case': document['case'],
        'lastAccessed': document['lastAccessed'],
        'liked': !document['liked'],
        'user': document['user']
      });
    } else {
      Firestore.instance.collection("user_case_relation").add({
        'case': casee.id,
        'lastAccessed': null,
        'liked': true,
        'user': widget.user
      });
    }

    setState(() {
      int index = cases.indexOf(casee);
      cases[index].setLiked(!cases[index].isLiked());
    });
  }

  IconData getLikeIcon(bool liked) {
    if (liked)
      return FontAwesomeIcons.solidHeart;
    else
      return FontAwesomeIcons.heart;
  }

  Future<Ong> getOng(String ongId) async {
    final documentOngSnapshot =
        await Firestore.instance.collection('ongs').document(ongId).get();

    final documentOng = documentOngSnapshot.data;
    Ong ong = Ong(
        city: documentOng["city"],
        email: documentOng["email"],
        id: documentOngSnapshot.documentID,
        name: documentOng["name"],
        state: documentOng["state"],
        whatsapp: documentOng["whatsapp"]);

    return ong;
  }

  void getAllCases() {
    Firestore.instance
        .collection('cases')
        .getDocuments()
        .then((casesSnapshot) async {
      List<DocumentSnapshot> documentSnapshots = casesSnapshot.documents;
      List<Case> casesAux = [];
      for (final documentCaseSnapshot in documentSnapshots) {
        final documentCase = documentCaseSnapshot.data;
        Ong ong = await getOng(documentCase["ong"]);

        Case casee = Case(
            description: documentCase["description"],
            id: documentCaseSnapshot.documentID,
            ong: ong,
            title: documentCase["title"],
            value: documentCase["valor"].toDouble());

        casesAux.add(casee);
      }

      casesAux = await getLikes(casesAux);

      setState(() {
        cases = casesAux;
      });
    });
  }

  Future<List<Case>> getLikes(List<Case> casesAux) async {
    for (Case casee in casesAux) {
      final result = await Firestore.instance
          .collection("user_case_relation")
          .where("case", isEqualTo: casee.id)
          .where("user", isEqualTo: widget.user)
          .limit(1)
          .getDocuments();

      if (result.documents.length > 0) {
        final document = result.documents[0].data;
        casee.setLiked(document["liked"]);

        final timestamp = document["lastAccessed"];
        if (timestamp != null) {
          casee.setLastAccessed(timestamp.toDate());
        }
      } else {
        casee.setLiked(false);
        casee.setLastAccessed(null);
      }
    }

    return casesAux;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    getAllCases();
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 4;
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
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                  child: Container(
                child: Column(
                  children: [
                    [
                      Container(
                        margin: EdgeInsets.only(
                            left: 16, right: 16, top: 40, bottom: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bem Vindo!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: secondary),
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(left: 16, right: 16, bottom: 30),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Explore os casos abaixo e salve o dia. Total de " +
                              cases.length.toString() +
                              " casos.",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                    cases
                        .map((casee) => Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                          width: screenWidth * 0.7,
                                          margin: EdgeInsets.only(
                                              top: 24, left: 20),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "ONG:",
                                            style: TextStyle(
                                                color: secondary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          )),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                            icon: FaIcon(
                                              getLikeIcon(casee.isLiked()),
                                              size: 18,
                                              color: primary,
                                            ),
                                            onPressed: () {
                                              likeAction(casee);
                                            }),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 8, left: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Text(casee.ong.name)),
                                  Container(
                                      margin:
                                          EdgeInsets.only(top: 24, left: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Caso:",
                                        style: TextStyle(
                                            color: secondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )),
                                  Container(
                                      margin: EdgeInsets.only(top: 8, left: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Text(casee.title)),
                                  Container(
                                      margin:
                                          EdgeInsets.only(top: 24, left: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Valor:",
                                        style: TextStyle(
                                            color: secondary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )),
                                  Container(
                                      margin: EdgeInsets.only(top: 8, left: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          "R\$ " + casee.value.toString())),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: screenWidth * 0.66,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 24),
                                        child: Text(
                                          "Ver mais detalhes",
                                          style: TextStyle(
                                              color: primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                            icon: FaIcon(
                                              FontAwesomeIcons.arrowRight,
                                              size: 15,
                                              color: primary,
                                            ),
                                            onPressed: null),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ))
                        .toList()
                  ].expand((element) => element).toList(),
                ),
              )),
            ),
            Container(
                height: 50,
                color: primary,
                child: Row(
                  children: <Widget>[
                    Container(
                        width: buttonWidth,
                        child: IconButton(
                            color: Colors.white,
                            icon: FaIcon(
                              FontAwesomeIcons.powerOff,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              exit(1);
                            })),
                    Container(
                        width: buttonWidth,
                        child: IconButton(
                          color: Colors.white,
                          icon: FaIcon(
                            FontAwesomeIcons.signOutAlt,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Auth().signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ));
                          },
                        )),
                    Container(
                        width: buttonWidth,
                        child: IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.solidHeart,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ListLiked(
                                      title: widget.title,
                                      user: widget.user,
                                    ),
                                  ));
                            })),
                    Container(
                        width: buttonWidth,
                        child: IconButton(
                            color: Colors.white,
                            icon: FaIcon(
                              FontAwesomeIcons.wrench,
                              color: Colors.white,
                            ),
                            onPressed: null)),
                  ],
                ))
          ],
        ));
  }
}
