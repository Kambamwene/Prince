import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi_web/profile.dart';
import 'package:ukumbi_web/register_hall.dart';
import 'package:ukumbi_web/responsive.dart';

import 'Bookings.dart';
import 'drawer.dart';
import 'functions.dart';
import 'login.dart';
import 'widgets.dart';

class Home extends StatefulWidget {
  final Owner owner;
  final List<Ukumbi> ukumbis;
  const Home({Key key, this.owner, this.ukumbis}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  //Future<List<Ukumbi>>ukumbis;
  Ukumbis kumbis;
  @override
  void initState() {
    kumbis = Provider.of<Ukumbis>(context, listen: false);
    kumbis.setUkumbis(widget.ukumbis);
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      kumbis.setUkumbis(widget.ukumbis);
    });*/
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Consumer<Ukumbis>(
            //stream: null,
            builder: (context, ukumbis, child) {
          return Column(
            children: [
              Container(
                  padding: (Responsive.isMobile(context))
                      ? const EdgeInsets.only(top: 10, left: 10)
                      : const EdgeInsets.all(0),
                  child: Row(
                    children: [
                      (Responsive.isMobile(context))
                          ? IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                if (_scaffoldKey.currentState.isDrawerOpen) {
                                  Navigator.of(context).pop();
                                } else {
                                  _scaffoldKey.currentState.openDrawer();
                                }
                              })
                          : const SizedBox.shrink(),
                    ],
                  )),
              Expanded(
                child: Row(
                  children: [
                    (!Responsive.isMobile(context))
                        ? SizedBox(width: 300, child: customDrawer())
                        : const SizedBox.shrink(),
                    Expanded(
                        //flex: 3,
                        child: Builder(builder: (context) {
                      switch (index) {
                        case 0:
                          return Bookings(ukumbis:widget.ukumbis,page:"all");
                        case 1:
                          return Bookings(ukumbis:widget.ukumbis,page:"upcoming");
                        case 2:
                          return RegisterHall(owner: widget.owner);
                        case 3:
                          return Profile(
                              owner: widget.owner, ukumbis: widget.ukumbis);
                        default:
                          return const Center(
                              child: Text("Still under construction"));
                      }
                    })),
                  ],
                ),
              ),
            ],
          );
        }),
        drawer: (Responsive.isMobile(context))
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: customDrawer())
            : null);
  }

  List<DrawerList> setDrawerListArray() {
    return <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Booking Requests',
        icon: Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.Bookings,
        labelName: 'Upcoming Bookings',
        isAssetsImage: true,
        imageName: 'assets/images/clock.png',
      ),
      DrawerList(
        index: DrawerIndex.Register,
        labelName: 'Register Hall',
        icon: Icon(Icons.add),
      ),
      DrawerList(
        index: DrawerIndex.Profile,
        labelName: 'Profile',
        icon: Icon(Icons.person),
      ),
    ];
  }

  Widget customDrawer() {
    List<DrawerList> drawerList = setDrawerListArray();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.only(top: 40.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius:60,
                      foregroundImage: (widget.owner.dp == null)
                            ? null
                            : NetworkImage(widget.owner.dp),
                      child:(widget.owner.dp == null)
                            ? const Icon(Icons.person, size: 100)
                            : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        widget.owner.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Divider(
              height: 1,
              color: AppTheme.grey.withOpacity(0.6),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(0.0),
                itemCount: drawerList.length,
                itemBuilder: (BuildContext context, int counter) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          index = counter;
                        });
                      },
                      child: Stack(
                        children: <Widget>[
                          Container(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 6.0,
                                  height: 46.0,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(4.0),
                                ),
                                drawerList[counter].isAssetsImage
                                    ? Container(
                                        width: 24,
                                        height: 24,
                                        child: Image.asset(
                                            drawerList[counter].imageName,
                                            color: index == counter
                                                ? Colors.blue
                                                : AppTheme.nearlyBlack),
                                      )
                                    : Icon(drawerList[counter].icon.icon,
                                        color: index == counter
                                            ? Colors.blue
                                            : AppTheme.nearlyBlack),
                                const Padding(
                                  padding: EdgeInsets.all(4.0),
                                ),
                                Text(
                                  drawerList[counter].labelName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: index == counter
                                        ? Colors.blue
                                        : AppTheme.nearlyBlack,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          index == counter
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                            0.75 -
                                        64,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(28),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(28),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(
              height: 1,
              color: AppTheme.grey.withOpacity(0.6),
            ),
            Column(
              children: <Widget>[
                ListTile(
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.darkText,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  trailing: const Icon(
                    Icons.power_settings_new,
                    color: Colors.red,
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text("Sign out"),
                              content: const Text(
                                  "Are you sure you want to sign out?"),
                              actions: [
                                TextButton(
                                  child: const Text("YES"),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(
                                      builder: (context) {
                                        return const Login();
                                      },
                                    ), (Route<dynamic> route) => false);
                                  },
                                ),
                                TextButton(
                                  child: Text("NO"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ]);
                        });
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ), (Route<dynamic> route) => false);
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
