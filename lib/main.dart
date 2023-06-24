import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:init_together_app/studentClassScreen.dart';
import 'authscreens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'studentHome.dart';
import 'firebase_service.dart';

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
  String starturl = "/";
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(FirebaseService().auth.currentUser != null){
    var userdata = await FirebaseService().getUserData(uid: FirebaseService().auth.currentUser!.uid);
    starturl = "/${userdata["userType"]}home";
  } else{
    starturl = "/";}
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "InitTogether",
    initialRoute: starturl,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF3b4af5),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    routes: {
      "/": (context) => const Login(),
      "/createAcct": (context) => const CreateAcct(),
      "/newpassword": (context) => const Text("password change"),
      "/studenthome": (context) => const StudentHomepage(),
      "/studentClasses": (context) => const StudentClassView(),
      "/studentClassDetail": (context) => const ClassDetailScreen(),
      "/parenthome": (context) => const Text("Parent home"),
      "/teacherhome": (context) => const Text("Teacher home"),
      "/addSchools": (context) => const Text("Add schools"),
      "/messages": (context) => const Text("Messages"),
      "/bugreporting": (context) => const Text("Report a bug"),
      "/tutorial": (context) => const Text("Tutorial"),
    },
  ));
}


