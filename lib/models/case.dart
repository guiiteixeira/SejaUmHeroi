import 'package:intl/intl.dart';
import 'dart:ffi';
import 'package:SejaUmHeroi/models/ong.dart';

class Case {
  String id;
  String description;
  Ong ong;
  String title;
  double value;
  bool liked = false;
  DateTime lastAccessed;

  Case({this.id, this.description, this.ong, this.title, this.value});

  isLiked() {
    return liked;
  }

  setLiked(bool liked) {
    this.liked = liked;
  }

  getLastAccessed() {
    return lastAccessed;
  }

  setLastAccessed(DateTime lastAccessed) {
    this.lastAccessed = lastAccessed;
  }

  getLastAccessedString() {
    DateFormat formatter = DateFormat('dd/MM/yyyy às HH:mm');
    return formatter.format(lastAccessed);
  }
}
