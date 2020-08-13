import 'package:SejaUmHeroi/auth/auth.dart';
import 'package:SejaUmHeroi/pages/home.dart';
import 'package:SejaUmHeroi/resources/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final name = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final confirm = TextEditingController();

  void register(context) async {
    String nameStr = name.text;
    String emailStr = email.text;
    String senhaStr = senha.text;
    String confirmStr = confirm.text;

    if (nameStr.trim().length < 6) {
      alertError("Nome deve conter o mínimo 6 caracteres", context);
      return;
    }

    if (!EmailValidator.validate(emailStr.trim())) {
      alertError("Email inválido", context);
      return;
    }

    if (senhaStr != confirmStr) {
      alertError("Senhas não correspondem", context);
      return;
    }

    final userWithEmail = await Firestore.instance
        .collection('user')
        .where("email", isEqualTo: emailStr.trim())
        .limit(1)
        .getDocuments();
    if (userWithEmail.documents.length > 0) {
      alertError("Email já cadastrado", context);
      return;
    }

    try {
      FirebaseUser user = await Auth().signUp(emailStr.trim(), senhaStr);
      Firestore.instance
          .collection("user")
          .document(user.uid)
          .setData({'name': nameStr.trim(), 'email': emailStr.trim()});

      Alert(
          context: context,
          title: "Cadastro efetuado",
          type: AlertType.success,
          desc: "Cadastro efetuado com sucesso",
          buttons: [
            DialogButton(
              color: primary,
              child: Text(
                "Prosseguir",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                        title: 'Seja um Herói',
                        user: user.uid,
                      ),
                    ));
              },
            )
          ]).show();
    } catch (e) {
      alertError(
          "Não foi possível efetuar o cadastro, tente novamente mais tarde",
          context);
      return;
    }
  }

  void alertError(String error, context) {
    Alert(
        context: context,
        title: "Erro ao cadastrar",
        type: AlertType.error,
        desc: error,
        buttons: [
          DialogButton(
            color: primary,
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
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Center(
            child: Container(
              height: 530,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: Text("Criar uma nova conta",
                        style: TextStyle(
                            color: primary.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                  ),
                  Container(
                    width: maxWidth,
                    margin: EdgeInsets.only(top: 20),
                    child: Text("Nome",
                        style: TextStyle(
                            color: secondary, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: maxWidth,
                    child: TextField(
                      controller: name,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Digite seu nome"),
                    ),
                  ),
                  Container(
                    width: maxWidth,
                    margin: EdgeInsets.only(top: 20),
                    child: Text("Email",
                        style: TextStyle(
                            color: secondary, fontWeight: FontWeight.bold)),
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
                    child: Text("Senha",
                        style: TextStyle(
                            color: secondary, fontWeight: FontWeight.bold)),
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
                    margin: EdgeInsets.only(top: 20),
                    child: Text("Confirmar senha",
                        style: TextStyle(
                            color: secondary, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: maxWidth,
                    child: TextField(
                      controller: confirm,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Digite sua senha novamente"),
                    ),
                  ),
                  Container(
                    width: maxWidth,
                    margin: EdgeInsets.only(top: 40, bottom: 40),
                    child: RaisedButton(
                      child: Text("Enviar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      onPressed: () {
                        register(context);
                      },
                      color: primary.shade900,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
