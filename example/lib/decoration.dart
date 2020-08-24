import 'package:flutter/material.dart';

final appThemeData = ThemeData(
  primaryColor: Color(0xFFF46842),
);

final buttonDecoration = new BoxDecoration(
    color: Color.fromRGBO(46, 204, 113, 1.0),
    borderRadius: new BorderRadius.circular(5),
    border: Border.all(color: Color.fromRGBO(39, 174, 96, 1.0)));

final videoPlayerFrameDecoration = BoxDecoration(
  color: Color.fromRGBO(236, 240, 241, 1.0),
  border: Border.all(color: Color.fromRGBO(185, 195, 199, 1.0), width: 1.0),
);

final dropdownButtonDecoration = BoxDecoration(
    color: Color.fromRGBO(155, 89, 182, 1.0),
    borderRadius: BorderRadius.circular(5),
    border: Border.all(color: Color.fromRGBO(142, 68, 173, 1.0)));

final outputDecoration = new BoxDecoration(
    borderRadius: BorderRadius.all(new Radius.circular(5)),
    color: Color.fromRGBO(241, 196, 15, 1.0),
    border: Border.all(color: Color.fromRGBO(243, 156, 18, 1.0)));

final buttonTextStyle = new TextStyle(
    fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white);

final hintTextStyle = new TextStyle(fontSize: 14, color: Colors.grey[400]);

final selectedTabColor = Color(0xFF1e90ff);
final unSelectedTabColor = Color(0xFF808080);

final tabBarDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(
      color: unSelectedTabColor,
      width: 1.0,
    ),
    bottom: BorderSide(
      width: 0.0,
    ),
  ),
);

final textFieldStyle = new TextStyle(fontSize: 14, color: Colors.black);

final dropdownButtonTextStyle = new TextStyle(
  fontSize: 14,
  color: Colors.black,
);

InputDecoration inputDecoration(String hintText) {
  return InputDecoration(
      border: const OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1.0)),
        borderRadius: const BorderRadius.all(
          const Radius.circular(5),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1.0)),
        borderRadius: const BorderRadius.all(
          const Radius.circular(5),
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromRGBO(52, 152, 219, 1.0)),
        borderRadius: const BorderRadius.all(
          const Radius.circular(5),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 12),
      hintStyle: hintTextStyle,
      hintText: hintText);
}
