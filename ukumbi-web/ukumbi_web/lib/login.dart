import 'dart:async';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ukumbi_web/admin.dart';
import 'package:ukumbi_web/responsive.dart';
import 'package:ukumbi_web/widgets.dart';

import 'functions.dart';
import 'home.dart';

StreamController<String> feedback = BehaviorSubject();
TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();
StreamController<Widget> function = BehaviorSubject();

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ScrollController controller = ScrollController();
  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        controller.position.outOfRange) {
      setState(() {
        //you can do anything here
      });
    }
    if (controller.offset <= controller.position.minScrollExtent &&
        !controller.position.outOfRange) {
      setState(() {
        //you can do anything here
      });
    }
  }

  @override
  void initState() {
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/images/hall-bg.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.darken))),
          child: Responsive.isDesktop(context)
              ? const DesktopLogin()
              : const MobileView()),
    );
  }
}

class MobileView extends StatelessWidget {
  const MobileView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Container(padding: const EdgeInsets.all(20), child: const LoginBox()),
    );
  }
}

class DesktopLogin extends StatelessWidget {
  const DesktopLogin({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  TextBox(
                      height: 50,
                      width: 350,
                      hint: "Username",
                      controller: username),
                  SizedBox(width: 20),
                  PasswordTextBox(
                    height: 50,
                    width: 350,
                    hint: "Password",
                    controller: password,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (username.text.isEmpty || password.text.isEmpty) {
                          feedback.add("Both fields must be filled");
                          return;
                        }
                        Owner owner =
                            await login(username.text, password.text, feedback);
                        if (owner != null) {
                          if (owner.username.toLowerCase() == "admin") {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const Admin();
                            }));
                          } else {
                            // ignore: missing_return
                            List<Ukumbi> ukumbis = await getUkumbis(owner);
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Home(owner: owner, ukumbis: ukumbis);
                            }));
                          }
                        }
                      },
                      child: const Text("Login"))),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            //Expanded(flex: 5, child: SizedBox.expand()),
            SizedBox(
              width: 600,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: CreateAccount(),
              ),
            )
          ],
        ))
      ],
    );
  }
}

class LoginBox extends StatefulWidget {
  const LoginBox({Key key}) : super(key: key);

  @override
  _LoginBoxState createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextBox(
                height: 50,
                //width: 350,
                hint: "Username",
                controller: username),
            SizedBox(height: 20),
            PasswordTextBox(
              height: 50,
              //width: 350,
              hint: "Password",
              controller: password,
            ),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                    onPressed: () async {
                      if (username.text.isEmpty || password.text.isEmpty) {
                        feedback.add("Both fields must be filled");
                        return;
                      }
                      Owner owner =
                          await login(username.text, password.text, feedback);
                      if (owner != null) {
                        // ignore: missing_return
                        List<Ukumbi> ukumbis = await getUkumbis(owner);
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return Home(owner: owner, ukumbis: ukumbis);
                        }));
                      }
                    },
                    child: const Text("Login"))),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder(
            stream: feedback.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.data,
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10)
                ],
              );
            }),
        TextButton(
            child: const Center(
              child:
                  Text("Create Account", style: TextStyle(color: Colors.red)),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return Scaffold(
                    body: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: const AssetImage("assets/images/hall-bg.jpg"),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.4),
                              BlendMode.darken))),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CreateAccount(),
                  ),
                ));
              }));
            })
      ],
    );
  }
}

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  FilePickerResult result;
  //StreamController<List<int>> photo = BehaviorSubject();
  StreamController<String> usernameresponse = BehaviorSubject();
  StreamController<String> feedback = BehaviorSubject();
  ImageProvider dp;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController phone = TextEditingController();
  bool usernameAvailable;
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      isAlwaysShown: true,
      child: ListView(
        //mainAxisSize: MainAxisSize.min,

        children: [
          const SizedBox(
              height: 60,
              child: Text(
                "Create Account",
                style: TextStyle(color: Colors.white, fontSize: 21),
                textAlign: TextAlign.center,
              )),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  foregroundImage: dp,
                ),
                // ignore: prefer_const_constructors
                Positioned.fill(
                    right: 20,
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                            child: const Icon(Icons.add_a_photo),
                            onTap: () async {
                              try {
                                result = await FilePicker.platform.pickFiles(
                                    type: FileType.image, withData: true);
                                setState(() {
                                  dp = MemoryImage(result.files[0].bytes);
                                });
                              } catch (err) {
                                result = null;
                              }
                            })))
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextBox(
              controller: username,
              //width:300,
              height: 50,
              //width:350,
              icon: Icons.person_outline,
              hint: 'Username',
              onSubmit: (value) async {}),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: usernameresponse.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(height: 0);
              }
              Color color = Colors.red;
              if (snapshot.data.toLowerCase().contains("available")) {
                color = Colors.white;
              }
              return Text(snapshot.data, style: TextStyle(color: color));
            },
          ),
          TextBox(
            controller: name,
            icon: Icons.person_outline,
            hint: 'Name',
            //width: 300,
            height: 50,
          ),
          const SizedBox(height: 10),
          TextBox(
            controller: phone,
            icon: Icons.phone_outlined,
            hint: 'Phone Number',
            //width: 300,
            height: 50,
          ),
          const SizedBox(height: 10),
          PasswordTextBox(
              controller: password,
              icon: Icons.lock_outline,
              hint: 'Password',
              //width: 300,
              height: 50),
          const SizedBox(height: 10),
          PasswordTextBox(
            controller: confirmPassword,
            icon: Icons.lock_outline,
            hint: 'Confirm Password',
            //width:300,
            height: 50,
          ),
          const SizedBox(height: 20),
          SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                  child: const Text("Register"),
                  onPressed: () async {
                    if (username.text.isEmpty ||
                        name.text.isEmpty ||
                        phone.text.isEmpty ||
                        password.text.isEmpty ||
                        confirmPassword.text.isEmpty) {
                      feedback.add("All fields must be filled");
                      return;
                    }
                    if (confirmPassword.text != password.text) {
                      feedback
                          .add("The passwords you have entered don't match");
                      return;
                    }

                    usernameAvailable =
                        await checkUsername(username.text, usernameresponse);
                    if (!usernameAvailable) {
                      feedback
                          .add("The username you have provided already exists");
                      return;
                    }
                    Owner owner = Owner();
                    owner.name = name.text;
                    owner.phoneNumber = phone.text;
                    owner.username = username.text;
                    owner.password = password.text;
                    Owner response =
                        await createAccount(owner, result, feedback);
                    if (response != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              Home(owner: response, ukumbis: [])));
                    }
                  })),
          const SizedBox(height: 10),
          StreamBuilder(
              stream: feedback.stream,
              initialData: "",
              builder: (context, snapshot) {
                return Text(
                  snapshot.data,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                );
              })
        ],
      ),
    );
  }
}
