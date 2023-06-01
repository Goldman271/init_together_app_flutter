import 'package:flutter/material.dart';
import 'authscreens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "InitTogether",
    initialRoute: '/',
    routes: {
      "/": (context) => const Login(),
      "/createAcct": (context) => const CreateAcct(),
      "/newpassword": (context) => const Text("password change"),
    },
  ));
}


