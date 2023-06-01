import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const LoginForm()
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Enter your username/email here"
            ),
            controller: usernameController,
    ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Enter password"
            ),
            controller: passwordController,
            ),
          Row(
            children: [
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: usernameController.text,
                            password: passwordController.text,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                        }
                      }
                    },
                    child: const Text("Submit")
                  )
          ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/newpassword');
                  },
                  child: const Text("Forgot password?")
                )
              )
          ]
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40.0),
            child:
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/createAcct");
                },
                child: const Text("Create New Account")
              )
          )
        ]
      ),
    );
  }
}

class CreateAcct extends StatelessWidget {
  const CreateAcct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Account'),
      ),
      body: const CreateAcctForm()
    );
  }
}

class CreateAcctForm extends StatefulWidget {
  const CreateAcctForm({super.key});

  @override
  State<CreateAcctForm> createState() => CreateAcctFormState();
}

class CreateAcctFormState extends State<CreateAcctForm> {
  final GlobalKey<FormState> _accountFormKey = GlobalKey<FormState>();
  String? dropdownValue;
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
    child: Form(
      key: _accountFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                  hintText: "What is your email?"
              ),

            ),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: "Type in a username (max 20 characters)"
              ),
              maxLength: 20,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: "Type in a password (max 20 characters)"
              ),
              maxLength: 20,
            ),
            TextFormField(controller: password2controller,
            decoration: const InputDecoration(
                hintText: "Type in a password (max 20 characters)"
            ),
            validator: (value) {
              if(value != passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            }),
            DropdownButtonFormField(
              value: dropdownValue,
              items: const [DropdownMenuItem(value: "student", child: Text("Student")),
                DropdownMenuItem(value: "parent", child: Text("Parent"))],
              onChanged: (value) {setState(() {
                dropdownValue = value!;
                print(dropdownValue);
              });},


            ),
            Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            if(passwordController.text == password2controller.text){try {
                              UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text
                              );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                print('The password provided is too weak.');
                              } else if (e.code == 'email-already-in-use') {
                                print('The account already exists for that email.');
                              }
                            } catch (e) {
                              print(e);
                            }
                          }},
                          child: const Text("Submit")
                      )
                  )
                ]
            )
          ]
      ),
    ));
  }
}
