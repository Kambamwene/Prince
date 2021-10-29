import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'functions.dart';

class AppTheme {
  AppTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'WorkSans';

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );
}

class TextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final double width;
  final Function onSubmit;
  final double height;
  final int maxLines;
  const TextBox({
    Key key,
    this.controller,
    this.hint,
    this.onSubmit,
    this.icon,
    this.maxLines,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        //color: Colors.white54,
        //decoration: BoxDecoration(
        //color: Colors.white24,
        //boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 1)]),
        child: TextField(
            minLines: null,
            maxLines: null,
            onSubmitted: onSubmit,
            controller: controller,
            //maxLines:maxLines,
            expands: true,
            decoration: InputDecoration(
                filled: true,
                prefixIcon:Icon(icon),
                fillColor: Colors.white70,
                hintText: hint,
                border: InputBorder.none)));
  }
}

class PasswordTextBox extends TextBox {
  final bool obscureText;
  const PasswordTextBox(
      {this.obscureText,
      Key key,
      TextEditingController controller,
      double height,
      IconData icon,
      double width,
      String hint})
      : super(
            controller: controller,
            height: height,
            width: width,
            icon:icon,
            hint: hint,
            key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        width: width,
        /*decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10))),*/
        //color: Colors.white54,
        //decoration: BoxDecoration(
        //color: Colors.white24,
        //boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 1)]),
        child: TextField(
            controller: controller,
            //maxLines:maxLines,
            //expands: true,
            obscureText: true,
            decoration: InputDecoration(
                filled: true,
                prefixIcon: Icon(icon),
                fillColor: Colors.white70,
                hintText: hint,
                border: const OutlineInputBorder())));
  }
}

class Ukumbis with ChangeNotifier {
  List<Ukumbi> ukumbis = [];
  void addUkumbi(Ukumbi ukumbi) {
    ukumbis.add(ukumbi);
    notifyListeners();
  }

  void setUkumbis(List<Ukumbi> kumbis) {
    ukumbis = [];
    ukumbis.addAll(kumbis);
    notifyListeners();
  }

  void deleteUkumbi(Ukumbi ukumbi) {
    ukumbis.remove(ukumbi);
    notifyListeners();
  }
}

Widget Spacer(double height) {
  return SizedBox(height: height);
}

class Screen{
  final BuildContext context;
  Screen(this.context){
    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;
  }
  double width;
  double height;
}