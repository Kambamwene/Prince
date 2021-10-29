import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi_web/responsive.dart';

import 'functions.dart';
import 'login.dart';

class Admin extends StatefulWidget {
  const Admin({Key key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Color> menuColors = List.filled(3, Colors.black);
  int index = 0;
  @override
  Widget build(BuildContext context) {
    for (int n = 0; n < menuColors.length; ++n) {
      if (n == index) {
        menuColors[n] = Colors.blue;
      } else {
        menuColors[n] = Colors.black;
      }
    }
    return Scaffold(
        key: _scaffoldKey,
        drawer: Responsive.isMobile(context) ? drawer() : null,
        body: Column(
          children: [
            Responsive.isMobile(context)
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            if (_scaffoldKey.currentState.isDrawerOpen) {
                              Navigator.of(context).pop();
                            } else {
                              _scaffoldKey.currentState.openDrawer();
                            }
                          },
                        )
                      ],
                    ))
                : const SizedBox.shrink(),
            Expanded(
                child: Row(
              children: [
                !Responsive.isMobile(context)
                    ? SizedBox(width: 250, child: drawer())
                    : const SizedBox.shrink(),
                Builder(builder: (context) {
                  switch (index) {
                    case 0:
                      return const Users();
                      break;
                    case 1:
                      return const Owners();
                      break;
                    default:
                      return const SizedBox.expand(
                          child: Text("Still under construction"));
                  }
                })
              ],
            ))
          ],
        ));
  }

  Widget drawer() {
    return Drawer(
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Card(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircleAvatar(
                    radius: 60,
                    child: Text(
                      "Admin",
                      style: TextStyle(color: Colors.white),
                    )),
                const Divider(),
                TextButton(
                  child: Text("Manage Users",
                      style: TextStyle(color: menuColors[0])),
                  onPressed: () {
                    setState(() {
                      index = 0;
                    });
                  },
                ),
                TextButton(
                  child: Text("Manage Owners",
                      style: TextStyle(color: menuColors[1])),
                  onPressed: () {
                    setState(() {
                      index = 1;
                    });
                  },
                ),
                TextButton(
                  child: const Text("Logout",
                      style: TextStyle(
                        color: Colors.red,
                      )),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (route) => false);
                  },
                )
              ],
            ))));
  }
}

class Owners extends StatefulWidget {
  const Owners({Key key}) : super(key: key);

  @override
  _OwnersState createState() => _OwnersState();
}

class _OwnersState extends State<Owners> {
  Future<List<Owner>> owners;
  Owner selectedOwner;
  List<StreamController<String>> feedback = [];
  StreamController<String> ukumbifeedback = BehaviorSubject();
  @override
  void initState() {
    owners = getAllOwners();
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in feedback) {
      controller.close();
    }
    ukumbifeedback.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
          future: owners,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            feedback=[];
            for (int n = 0; n < snapshot.data.length; ++n) {
              feedback.add(BehaviorSubject());
            }
            return Row(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        if (snapshot.data[index].username.toLowerCase() ==
                            "admin") {
                          return const SizedBox.shrink();
                        }
                        return Card(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedOwner = snapshot.data[index];
                                    });
                                  },
                                  child: ListTile(
                                      title: Text(snapshot.data[index].name),
                                      subtitle: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "@${snapshot.data[index].username}"),
                                          Text(
                                              snapshot.data[index].phoneNumber),
                                          Text(snapshot.data[index].password,
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic))
                                        ],
                                      ),
                                      leading: (snapshot.data[index].dp == null)
                                          ? const Icon(Icons.person)
                                          : CircleAvatar(
                                              foregroundImage: NetworkImage(
                                                  snapshot.data[index].dp),
                                            )),
                                )),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      for (int n = 0;
                                          n < snapshot.data.length;
                                          ++n) {
                                        feedback[n].add(null);
                                      }
                                      List<Ukumbi> halls = await getUkumbis(
                                          snapshot.data[index]);
                                      bool response = await deleteOwner(
                                          snapshot.data[index],
                                          halls,
                                          feedback[index]);
                                      if (response) {
                                        feedback[index].add(null);
                                        setState(() {
                                          owners = getAllOwners();
                                        });
                                      }
                                      if(!response){
                                        feedback[index].add("This hall couldn't be deleted");
                                      }
                                    })
                              ],
                            ),
                            StreamBuilder(
                                stream: feedback[index].stream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(snapshot.data,
                                      textAlign: TextAlign.center);
                                })
                          ],
                        ));
                      }),
                ),
                SizedBox(
                    width: 300,
                    height: MediaQuery.of(context).size.height,
                    child: Card(
                        elevation: 4,
                        child: Builder(builder: (context) {
                          if (selectedOwner == null) {
                            return const Center(
                                child:
                                    Text("Select an owner to view more info"));
                          }
                          return Column(children: [
                            const Text("Halls"),
                            const Divider(),
                            Expanded(
                                child: (selectedOwner.halls.isEmpty)
                                    ? const Center(
                                        child: Text(
                                            "This manager has no halls yet"))
                                    : Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount:
                                                    selectedOwner.halls.length,
                                                itemBuilder: (context, index) {
                                                  if (selectedOwner
                                                          .halls[index] ==
                                                      null) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  return Card(
                                                    child: FutureBuilder(
                                                        future: selectedOwner
                                                            .halls[index]
                                                            .get(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot
                                                              .hasData) {
                                                            return const Center(
                                                                child:
                                                                    CircularProgressIndicator());
                                                          }
                                                          if (!snapshot
                                                              .data.exists) {
                                                            return const SizedBox
                                                                .shrink();
                                                          }
                                                          Ukumbi ukumbi =
                                                              mapToUkumbi(
                                                                  snapshot.data
                                                                      .data());
                                                          return SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.25,
                                                              child: Swiper(
                                                                  controller:
                                                                      SwiperController(),
                                                                  itemCount: ukumbi
                                                                      .images
                                                                      .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Stack(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              double.infinity,
                                                                          child: Image.network(
                                                                              ukumbi.images[index],
                                                                              fit: BoxFit.cover),
                                                                        ),
                                                                        Positioned.fill(
                                                                            top: 5,
                                                                            child: Align(
                                                                                alignment: Alignment.topRight,
                                                                                child: IconButton(
                                                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                                                  onPressed: () async {
                                                                                    String response = await deleteUkumbi(selectedOwner, snapshot.data[index], ukumbifeedback);
                                                                                    if (response == "SUCCESS") {
                                                                                      setState(() {
                                                                                        selectedOwner.halls.remove(snapshot.data[index]);
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                ))),
                                                                        Positioned(
                                                                          top:
                                                                              20.0,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                                            color:
                                                                                Colors.black.withOpacity(0.7),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: <Widget>[
                                                                                Text(ukumbi.name, style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                                Text(ukumbi.location, style: const TextStyle(color: Colors.white))
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                  pagination:
                                                                      const SwiperPagination()));
                                                        }),
                                                  );
                                                }),
                                          ),
                                          StreamBuilder(
                                              stream:ukumbifeedback.stream,
                                              builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const SizedBox.shrink();
                                            }
                                            return Text(snapshot.data);
                                          })
                                        ],
                                      ))
                          ]);
                        })))
              ],
            );
          }),
    );
  }
}

class Users extends StatefulWidget {
  const Users({Key key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Future<List<User>> users;
  List<StreamController<String>> feedback = [];
  @override
  void initState() {
    users = getAllUsers();
    super.initState();
  }

  @override
  void dispose() {
    for (int n = 0; n < feedback.length; ++n) {
      feedback[n].close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
          future: users,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            for (int n = 0; n < snapshot.data.length; ++n) {
              feedback.add(BehaviorSubject());
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Card(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: ListTile(
                                title: Text(snapshot.data[index].name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("@${snapshot.data[index].username}"),
                                    Text((snapshot.data[index].phoneNumber ==
                                            null)
                                        ? ""
                                        : snapshot.data[index].phoneNumber),
                                    Text(snapshot.data[index].password,
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic))
                                  ],
                                ),
                                leading: (snapshot.data[index].dp == null)
                                    ? const Icon(Icons.person)
                                    : CircleAvatar(
                                        foregroundImage: NetworkImage(
                                            snapshot.data[index].dp),
                                      ))),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            for (int n = 0; n < feedback.length; ++n) {
                              feedback[n].add(null);
                            }
                            String response = await deleteUser(
                                snapshot.data[index], feedback[index]);
                            if (response == "SUCCESS") {
                              setState(() {
                                users = getAllUsers();
                              });
                              feedback[index].add(null);
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    StreamBuilder(
                        stream: feedback[index].stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          } else {
                            return Text(
                              snapshot.data,
                              textAlign: TextAlign.center,
                            );
                          }
                        })
                  ],
                ));
              },
            );
          }),
    );
  }
}
