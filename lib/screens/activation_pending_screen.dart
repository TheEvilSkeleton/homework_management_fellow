import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homework_management_fellow/screens/task_screen.dart';
import 'package:homework_management_fellow/services/firebaseService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homework_management_fellow/model/student.dart';

class ActivationPendingScreen extends StatefulWidget {
  static const String id = 'ActivationPendingScreen';

  @override
  _ActivationPendingScreenState createState() => _ActivationPendingScreenState();
}

class _ActivationPendingScreenState extends State<ActivationPendingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> offset;
  bool isActivate;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: Duration(seconds: 1));

    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0)).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Gradient gradient1 = LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]);
    Gradient gradient2 = LinearGradient(colors: [Colors.orangeAccent, Colors.pinkAccent]);
    Shader shader1 = gradient1.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    Shader shader2 = gradient2.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Future<bool> checkUserStatus() async {
      final prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email');
      String uid = prefs.getString('uid');
      Student student =
          await Provider.of<FirebaseService>(context, listen: false).checkUser(email: email, uid: uid);
      if (student.activate == true) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Activation pending",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              foreground: Paint()..shader = shader2,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "PLease check later or press the button to refresh status",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              foreground: Paint()..shader = shader1,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Padding(
            padding: const EdgeInsets.all(19),
            child: SizedBox(
              width: 180,
              child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Color(0xFF2196f3),
                  textColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  onPressed: () {
                    isActivate = checkUserStatus();
                    if (isActivate == false) {
                      controller.reverse();
                      Future.delayed(Duration(seconds: 3), () {
                        controller.forward();
                      });
                    } else {
                      Navigator.pushNamed(context, TaskScreen.id);
                    }
                  }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: offset,
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Container(
                  child: Text('failed'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
