import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi_web/admin.dart';
import 'package:ukumbi_web/functions.dart';
import 'package:ukumbi_web/login.dart';
import 'package:ukumbi_web/widgets.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ListenableProvider<Ukumbis>(create: (context) => Ukumbis())],
      child: MaterialApp(
          title: 'Ukumbi',
          theme: ThemeData(
            textTheme:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: const Login()),
    );
  }
}

Widget testHome() {
  Owner owner;
  StreamController<String> feedback = BehaviorSubject();
  return FutureBuilder(
      future: login("prince", "mushiprince", feedback),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        owner = snapshot.data;
        return FutureBuilder(
            future: getUkumbis(owner),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              }
              return Home(
                owner: owner,
                ukumbis: snapshot.data,
              );
            });
      });
}
