import 'package:SejaUmHeroi/models/ong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:SejaUmHeroi/models/case.dart';
import 'package:SejaUmHeroi/resources/colors.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/services.dart';

class ListLiked extends StatefulWidget {
  ListLiked({this.title, this.user});

  final String title;
  final String user;

  @override
  _ListLikedState createState() => _ListLikedState();
}

class _ListLikedState extends State<ListLiked> {
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

  Future<Case> getCase(String caseId) async {
    final documentCaseSnapshot =
        await Firestore.instance.collection('cases').document(caseId).get();

    final documentCase = documentCaseSnapshot.data;
    Ong ong = await getOng(documentCase["ong"]);

    return Case(
        description: documentCase["description"],
        id: documentCaseSnapshot.documentID,
        ong: ong,
        title: documentCase["title"],
        value: documentCase["valor"].toDouble());
  }

  void getCases() {
    Firestore.instance
        .collection("user_case_relation")
        .where("user", isEqualTo: widget.user)
        .where("liked", isEqualTo: true)
        .getDocuments()
        .then((result) async {
      List<DocumentSnapshot> documentSnapshots = result.documents;
      List<Case> casesAux = [];

      for (final documentSnapshot in documentSnapshots) {
        Case casee = await getCase(documentSnapshot["case"]);
        casee.setLiked(documentSnapshot["liked"]);
        final timestamp = documentSnapshot["lastAccessed"];
        if (timestamp != null) {
          casee.setLastAccessed(timestamp.toDate());
        }
        casesAux.add(casee);
      }

      setState(() {
        cases = casesAux;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    getCases();
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
        child: Container(
          child: Column(
            children: [
              [
                Container(
                    margin: EdgeInsets.only(
                        left: 16, right: 16, top: 40, bottom: 20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Casos favoritos",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: secondary),
                    ))
              ],
              cases
                  .map((casee) => Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                    width: screenWidth * 0.7,
                                    margin: EdgeInsets.only(top: 24, left: 20),
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
                                margin: EdgeInsets.only(top: 24, left: 20),
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
                                margin: EdgeInsets.only(top: 24, left: 20),
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
                                child: Text("R\$ " + casee.value.toString())),
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
        ),
      ),
    );
  }
}
