import 'package:SejaUmHeroi/resources/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  final double normalPFont = 14;
  final double normalTFont_aumentadaPFont = 16;
  final double normalSTFont = 22;
  final double aumentadaTFont = 18;
  final double aumentadaSTFont = 24;

  static Config config = null;

  static Config instance() {
    if (config == null) {
      config = Config();
    }
    return config;
  }

  Future<double> getPFont() async {
    if ((await getFontPreference()) == "Normal") {
      return normalPFont;
    }
    return normalTFont_aumentadaPFont;
  }

  Future<double> getTFont() async {
    if ((await getFontPreference()) == "Normal") {
      return normalTFont_aumentadaPFont;
    }
    return aumentadaTFont;
  }

  Future<double> getSTFont() async {
    if ((await getFontPreference()) == "Normal") {
      return normalSTFont;
    }
    return aumentadaSTFont;
  }

  Future<Color> getSecondary() async {
    String theme = await getTheme();
    if (theme == "Dark") {
      return Colors.black;
    }
    return secondary;
  }

  Future<Color> getPrimary() async {
    String theme = await getTheme();
    if (theme == "Dark") {
      return Colors.black;
    }
    return primary.shade900;
  }

  Future<String> getFontPreference() async {
    return (await SharedPreferences.getInstance()).getString("font");
  }

  Future<String> getTheme() async {
    return (await SharedPreferences.getInstance()).getString("theme");
  }
}
