import 'package:flutter/material.dart';

class MaterialColors {
  const MaterialColors();

  final MaterialColor primarySwatch = const MaterialColor(
    0xFFFF4081,
    <int, Color>{
      50: Color(0xFFFFF1F3),
      100: Color(0xFFFFE0E9),
      200: Color(0xFFFFB8D3),
      300: Color(0xFFFF8AC1),
      400: Color(0xFFFF68AE),
      500: Color(0xFFFF4081),
      600: Color(0xFFF50057),
      700: Color(0xFFF50057),
      800: Color(0xFFF50057),
      900: Color(0xFFF50057),
    },
  );

  static const MaterialColor secondary = MaterialColor(
    0xFFD47A9B,
    <int, Color>{
      50: Color.fromRGBO(212, 122, 155, .1),
      100: Color.fromRGBO(212, 122, 155, .2),
      200: Color.fromRGBO(212, 122, 155, .3),
      300: Color.fromRGBO(212, 122, 155, .4),
      400: Color.fromRGBO(212, 122, 155, .5),
      500: Color.fromRGBO(212, 122, 155, .6),
      600: Color.fromRGBO(212, 122, 155, .7),
      700: Color.fromRGBO(212, 122, 155, .8),
      800: Color.fromRGBO(212, 122, 155, .9),
      900: Color.fromRGBO(212, 122, 155, 1),
    },
  );

  static MaterialColor getMaterialColor(Color color) {
    final int red = (color.r * 255).toInt();
    final int green = (color.g * 255).toInt();
    final int blue = (color.b * 255).toInt();

    final Map<int, Color> shades = <int, Color>{
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.toARGB32(), shades);
  }
}
