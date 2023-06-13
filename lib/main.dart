import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'authscreens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'studentHome.dart';

Map<int, Color> color =
{
  50: const Color.fromRGBO(59, 74, 245, .1),
  100:const Color.fromRGBO(59, 74, 245, .2),
  200:const Color.fromRGBO(59, 74, 245, .3),
  300:const Color.fromRGBO(59, 74, 245, .4),
  400:const Color.fromRGBO(59, 74, 245, .5),
  500:const Color.fromRGBO(59, 74, 245, .6),
  600:const Color.fromRGBO(59, 74, 245, .7),
  700:const Color.fromRGBO(59, 74, 245, .8),
  800:const Color.fromRGBO(59, 74, 245, .9),
  900:const Color.fromRGBO(59, 74, 245, 1),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "InitTogether",
    initialRoute: '/',
    theme: ThemeData(
      primarySwatch: MaterialColor(0xFF3b4af5, color)
    ),
    routes: {
      "/": (context) => const Login(),
      "/createAcct": (context) => const CreateAcct(),
      "/newpassword": (context) => const Text("password change"),
      "/studenthome": (context) => const StudentNavDrawer(),
      "/parenthome": (context) => const Text("Parent home"),
      "/teacherhome": (context) => const Text("Teacher home"),
    },
  ));
}


