import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi/custom_widgets.dart';

import '../modules.dart';
import 'ukumbi_app_theme.dart';

Color orangeColors = const Color(0xffF5591F);
Color orangeLightColors = const Color(0xffF2861E);
StreamController<Widget> page;

class Profile extends StatefulWidget {
  const Profile({Key key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<User> user;
  @override
  void initState() {
    user = readUser();
    page = BehaviorSubject();
    super.initState();
  }

  @override
  void dispose() {
    page.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Theme(
      data: HotelAppTheme.buildLightTheme(),
      child: FutureBuilder(
        future: user,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.username == "NULL") {
            return const LoginOrRegister();
          }
          return ProfilePage(user: snapshot.data);
        },
      ),
    ));
  }
}

class LoginOrRegister extends StatelessWidget {
  const LoginOrRegister({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Widget>(
        stream: page.stream,
        initialData: const Body(),
        builder: (context, snapshot) {
          return snapshot.data;
        });
  }
}

class Body extends StatelessWidget {
  const Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/hall-bg.jpg"),
              fit: BoxFit.cover)),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(48.0),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10.0)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.0,
              sigmaY: 1.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.holiday_village_outlined,
                  size: 64,
                  color: Colors.grey.shade800,
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Find a hall now!",
                  style: TextStyle(
                      color: HotelAppTheme.buildLightTheme().primaryColorDark,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                const Text(
                    "To book halls and gain access to their owners you must login or create an account if you do not have one",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0)),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    elevation: 0,
                    highlightElevation: 0,
                    color: HotelAppTheme.buildLightTheme().primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: const Text("Create Account"),
                    onPressed: () {
                      page.add(const Register());
                    },
                  ),
                ),
                const SizedBox(height: 30.0),
                Text.rich(TextSpan(children: [
                  const TextSpan(text: "Already have account? "),
                  WidgetSpan(
                      child: InkWell(
                    onTap: () {
                      page.add(const Login());
                    },
                    child: Text("Log in",
                        style: TextStyle(
                          color:
                              HotelAppTheme.buildLightTheme().primaryColorDark,
                          fontWeight: FontWeight.bold,
                        )),
                  ))
                ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Login extends StatelessWidget {
  const Login({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextEditingController username = TextEditingController();
    TextEditingController password = TextEditingController();
    StreamController<String> feedback = BehaviorSubject();
    return Scaffold(
      //backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                TextBox(
                    controller: username, hint: "Username", icon: Icons.person),
                const SizedBox(
                  height: 20,
                ),
                TextBox(
                  controller: password,
                  hint: "Password",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100)),
                        color: HotelAppTheme.buildLightTheme().primaryColor,
                      ),
                      child: FlatButton(
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18),
                        ),
                        onPressed: () async {
                          //Map<String,dynamic>usermap=<String,dynamic>{};
                          User user = await login(
                              username.text, password.text, feedback);
                          if (user != null) {
                            saveUser(user);
                            LoginStatus status = Provider.of<LoginStatus>(
                                context,
                                listen: false);
                            status.changeStatus(true);
                            NavigationIndex index =
                                Provider.of<NavigationIndex>(context,
                                    listen: false);
                            index.changeIndex(1);
                          }
                        },
                      ),
                    )),
                StreamBuilder(
                    stream: feedback.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      return Column(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(height: 10),
                        Text(snapshot.data)
                      ]);
                    }),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    "FORGOT PASSWORD ?",
                    style: TextStyle(
                        color: HotelAppTheme.buildLightTheme().primaryColorDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Don't have an Account ? ",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                    ),
                    TextButton(
                      onPressed: () {
                        page.add(const Register());
                      },
                      child: Text("Sign Up ",
                          style: TextStyle(
                              color:
                                  HotelAppTheme.buildLightTheme().primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  ImageProvider dp;
  FilePickerResult result;
  TextEditingController username = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController password = TextEditingController();
  StreamController<String> feedback = BehaviorSubject();
  @override
  void dispose() {
    username.dispose();
    name.dispose();
    email.dispose();
    phoneNumber.dispose();
    password.dispose();
    feedback.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Center(
              child: ListView(
                //shrinkWrap: true,
                //mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          foregroundImage: dp,
                          backgroundColor: Colors.black45,
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.add_a_photo, size: 30),
                              onPressed: () async {
                                try {
                                  result = await FilePicker.platform
                                      .pickFiles(withData: true);
                                  setState(() {
                                    dp = MemoryImage(result.files.first.bytes);
                                  });
                                } catch (err) {
                                  result = null;
                                }
                              },
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextInput(
                      hint: "Username",
                      icon: Icons.person,
                      controller: username),
                  TextInput(
                      hint: "Fullname", icon: Icons.person, controller: name),
                  TextInput(
                      hint: "Email", icon: Icons.email, controller: email),
                  TextInput(
                      hint: "Phone Number",
                      icon: Icons.call,
                      controller: phoneNumber),
                  TextInput(
                      hint: "Password",
                      obscureText: true,
                      icon: Icons.vpn_key,
                      controller: password),
                  const SizedBox(height: 5),
                  ButtonWidget(
                    caption: "Register",
                    onClick: () async {
                      if (username.text.isEmpty ||
                          password.text.isEmpty ||
                          name.text.isEmpty) {
                        feedback.add(
                            "The username, full name and password fields must be filled");
                        return;
                      }
                      Map<String, dynamic> map = <String, dynamic>{
                        "username": username.text,
                        "password": password.text,
                        "email": email.text,
                        "phoneNumber": phoneNumber.text,
                        "name": name.text
                      };
                      dynamic user = await createAccount(map, result, feedback);
                      if (user != null) {
                        await saveUser(user);
                        LoginStatus login =
                            Provider.of<LoginStatus>(context, listen: false);
                        login.changeStatus(true);
                        NavigationIndex navigator =
                            Provider.of<NavigationIndex>(context,
                                listen: false);
                        navigator.changeIndex(1);
                      }
                    },
                  ),
                  const SizedBox(height: 5),
                  StreamBuilder(
                    stream: feedback.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          Text(snapshot.data, textAlign: TextAlign.center),
                          const SizedBox(height: 5)
                        ],
                      );
                    },
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        page.add(const Login());
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                              text: "Already a member ? ",
                              style: TextStyle(color: Colors.black)),
                          TextSpan(
                              text: "Login",
                              style: TextStyle(
                                  color: HotelAppTheme.buildLightTheme()
                                      .primaryColorDark)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({Key key, this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<User> userWeb;
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  FilePickerResult result;
  @override
  void initState() {
    userWeb = getUser(widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          FutureBuilder(
              initialData: widget.user,
              future: userWeb,
              builder: (context, snapshot) {
                email.text = snapshot.data.email;
                phone.text = snapshot.data.phoneNumber;
                return ProfileHeader(
                  user: widget.user,
                  avatar: (snapshot.data.dp == null)
                      ? const AssetImage("assets/images/user-default.png")
                      : CachedNetworkImageProvider(widget.user.dp),
                  coverImage: const AssetImage("assets/images/cover-hall.jpg"),
                  title: widget.user.name,
                  subtitle: widget.user.username,
                  actions: <Widget>[
                    MaterialButton(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 0,
                      child: const Icon(Icons.edit),
                      onPressed: () {},
                    )
                  ],
                );
              }),
          const SizedBox(height: 10.0),
          UserInfo(widget.user, email, phone),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ButtonWidget(
                  caption: "Logout",
                  onClick: () async {
                    await deleteUser();
                    NavigationIndex index =
                        Provider.of<NavigationIndex>(context, listen: false);
                    index.changeIndex(1);
                    LoginStatus login =
                        Provider.of<LoginStatus>(context, listen: false);
                    login.changeStatus(false);
                  }))
        ],
      ),
    );
  }

  Widget UserInfo(
      User user, TextEditingController email, TextEditingController phone) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            alignment: Alignment.topLeft,
            child: const Text(
              "User Information",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Card(
            child: Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ...ListTile.divideTiles(
                        color: Colors.grey,
                        tiles: [
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text("Email"),
                            subtitle: TextField(
                              controller: email,
                              onSubmitted: (value) async {
                                user.email = value;
                                saveUser(user);
                                await updateUser({
                                  "username": user.username,
                                  "email": user.email
                                });
                              },
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text("Phone"),
                            subtitle: TextField(
                                controller: phone,
                                onSubmitted: (value) async {
                                  user.phoneNumber = value;
                                  saveUser(user);
                                  await updateUser({
                                    "username": user.username,
                                    "phoneNumber": user.phoneNumber
                                  });
                                },
                                decoration: const InputDecoration(
                                    border: InputBorder.none)),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final ImageProvider<dynamic> coverImage;
  final ImageProvider<dynamic> avatar;
  final String title;
  final User user;
  final String subtitle;

  final List<Widget> actions;

  const ProfileHeader(
      {Key key,
      @required this.coverImage,
      @required this.user,
      @required this.avatar,
      @required this.title,
      this.subtitle,
      this.actions})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    FilePickerResult result;
    ImageProvider dp = avatar;
    return Stack(
      children: <Widget>[
        Ink(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(image: coverImage, fit: BoxFit.cover),
          ),
        ),
        Ink(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.black38,
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 160),
          child: Column(
            children: <Widget>[
              StatefulBuilder(builder: (context, setState) {
                return Stack(
                  children: [
                    Avatar(
                      image: dp,
                      radius: 40,
                      backgroundColor: Colors.white,
                      borderColor: Colors.grey.shade300,
                      borderWidth: 4.0,
                    ),
                    Positioned(
                        bottom: 0,
                        right: -10,
                        child: IconButton(
                            icon: Icon(Icons.add_a_photo,
                                color: HotelAppTheme.buildLightTheme()
                                    .primaryColor),
                            onPressed: () async {
                              try {
                                result = await FilePicker.platform.pickFiles(
                                    type: FileType.image, withData: true);
                              } catch (err) {
                                result = null;
                              }
                              if (result != null) {
                                setState(() {
                                  dp = MemoryImage(result.files.first.bytes);
                                });
                                String url = await uploadDp(result);
                                if (url != null) {
                                  user.dp = url;
                                  saveUser(user);
                                  await updateUser(
                                      {"username": user.username, "dp": url});
                                }
                              }
                            }))
                  ],
                );
              }),
              Text(
                title,
                style: Theme.of(context).textTheme.title,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5.0),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ]
            ],
          ),
        )
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  final ImageProvider<dynamic> image;
  final Color borderColor;
  final Color backgroundColor;
  final double radius;
  final double borderWidth;

  const Avatar(
      {Key key,
      @required this.image,
      this.borderColor = Colors.grey,
      this.backgroundColor,
      this.radius = 30,
      this.borderWidth = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius + borderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ?? HotelAppTheme.buildLightTheme().primaryColor,
        child: CircleAvatar(
          radius: radius - borderWidth,
          backgroundImage: image,
        ),
      ),
    );
  }
}
