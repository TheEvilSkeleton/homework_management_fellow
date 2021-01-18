import 'package:flutter/material.dart';
import 'package:homework_management_fellow/screens/registration_screen.dart';
import 'package:homework_management_fellow/screens/task_screen.dart';
import 'package:homework_management_fellow/widgets/sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'WelcomeScreen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner = false;
  String uid;
  String email;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      LocalStorage(name: uid, value: "uid").getLoginInfo();
      LocalStorage(name: email, value: "email").getLoginInfo();
      // getLoginInfo(uid, "uid");
      // getLoginInfo(email, "email");
      if (uid != null || email != null) {
        Navigator.pushNamed(context, TaskScreen.id);
      }
    });
    super.initState();
  }

  void getLoginInfo(String name, String value) async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString(value);
    print("chcvhgmvjhfjvfyvfjyjfjhfjhhjfhjhjfhfhgg$name");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Gradient gradient = LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]);
    Shader shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     registeredCheck("xxx@xx.com");
      //   },
      //   child: Icon(Icons.download_rounded),
      // ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Homework management fellow", style: TextStyle(fontSize: 25)),
                SizedBox(
                  height: 50,
                ),
                Text(
                  "No icon was designed",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()..shader = shader,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                OutlineButton(
                  splashColor: Colors.grey,
                  onPressed: () => buttonOnPressed(showSpinner),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  highlightElevation: 0,
                  borderSide: BorderSide(color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(image: AssetImage("images/google_logo.png"), height: 35.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'Sign/Log in with Google',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> buttonOnPressed(bool showSpinner) async {
    String email;
    String uid;
    bool isRegistered;
    setState(() {
      showSpinner = true;
    });
    signInWithGoogle().then(
      (result) async {
        email = result[0];
        isRegistered = await registeredCheck(email);
        setState(() {
          showSpinner = false;
        });
        if (email != null) {
          if (isRegistered == false) {
            Navigator.pushNamed(context, RegistrationScreen.id);
          } else {
            Navigator.pushNamed(context, TaskScreen.id);
          }
        } else {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              title: Text("Login failed"),
              content: Text("Please try again"),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Dismiss"))
              ],
            ),
          );
        }
      },
    );
  }

  Future<bool> registeredCheck(String email) async {
    var userInfo = await _firestore.collection("user").get();
    for (var userInf in userInfo.docs) {
      if (userInf.data()["email"] == email) {
        return true;
      }
    }
    return false;
  }
}

class LocalStorage {
  String name;
  String value;

  LocalStorage({this.name, this.value});

  void saveLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(name, value);
  }

  void getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString(value);
    print("{$value}chcvhgmvjhfjvfyvfjyjfjhfjhhjfhjhjfhfhgg$name");
  }
}