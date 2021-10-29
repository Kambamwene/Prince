import 'package:flutter/material.dart';
import 'package:ukumbi/screens/ukumbi_app_theme.dart';

import 'modules.dart';

class NavigationIndex with ChangeNotifier {
  int index = 0;
  void changeIndex(int newIndex) {
    index = newIndex;
    notifyListeners();
  }
}

class LoginStatus with ChangeNotifier {
  bool login = false;
  void changeStatus(bool status) {
    login = status;
    notifyListeners();
  }
}

class UkumbiProvider with ChangeNotifier {
  Ukumbi ukumbi;
  void setUkumbi(Ukumbi hall) {
    ukumbi = hall;
    notifyListeners();
  }
}

class Authentication with ChangeNotifier {
  bool enabled;
  void authenticate(bool value) {
    enabled = value;
    notifyListeners();
  }
}

class TextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Function onChanged;
  final IconData icon;
  const TextBox(
      {Key key,
      this.controller,
      this.hint,
      this.icon,
      this.onChanged,
      this.obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Material(
        elevation: 2.0,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        child: TextField(
          onChanged: onChanged,
          obscureText: obscureText,
          cursorColor: Colors.deepOrange,
          controller: controller,
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Material(
                elevation: 0,
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                child: Icon(
                  icon,
                  color: HotelAppTheme.buildLightTheme().primaryColor,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final IconData icon;
  const TextInput(
      {Key key,
      this.controller,
      this.hint,
      this.icon,
      this.obscureText = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(left: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String caption;
  final Function onClick;

  const ButtonWidget({Key key, this.caption = "", this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: HotelAppTheme.buildLightTheme().primaryColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          caption,
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class Ukumbis with ChangeNotifier {
  List<Ukumbi> ukumbis = [];
  List<Ukumbi>defaultUkumbis=[];
  void updateHalls(List<Ukumbi> halls) {
    ukumbis = [];
    ukumbis.addAll(halls);
    notifyListeners();
  }
  void resetDefault(){
    ukumbis=[];
    ukumbis.addAll(defaultUkumbis);
  }
  void initialize(List<Ukumbi>halls){
    ukumbis=[];
    defaultUkumbis=[];
    ukumbis.addAll(halls);
    defaultUkumbis.addAll(halls);
    notifyListeners();
  }
}
