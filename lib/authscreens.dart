import 'package:flutter/material.dart';
import 'firebase_service.dart';


class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text('Login', style: TextStyle(color: Colors.white)),
        centerTitle: true,
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
  bool loginfail = false;
  String error = "Login unsuccessful";

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 13),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Username/email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  errorText: loginfail ? error : null,
                ),
                controller: usernameController,
              ),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 13),
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    errorText: loginfail ? error : null,
                ),
                controller: passwordController,
              ),),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/newpassword');
                      },
                      child: const Text("Forgot password?")
                  )
              ),),
            Center(
              child:
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 32.0),
                child: ElevatedButton(
                  onPressed: () async {
                    String result = await FirebaseService().LoginUser(email: usernameController.text, password: passwordController.text);
                    if(result != "failure" && result != "user not found" && result != 'Wrong password provided for that user'){
                      usernameController.clear();
                      passwordController.clear();
                      if (mounted) {Navigator.of(context).pop();} else {}
                      Navigator.pushNamed(context, result);} else {
                      setState((){error = result;
                      loginfail = true;});
                      }}
                    ,
                  child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
                      child:Text("Login", style: TextStyle(color: Colors.white))
                  ),),
              ),),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30.0),
                child:
                Center(child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/createAcct");
                    },
                    child: const Text("Create New Account")

                ))
            )
          ]
      ),
    ));
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
  TextEditingController fullnameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2controller = TextEditingController();
  bool createfail = false;
  String error = "Make sure you have filled in all fields.";

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
              decoration: InputDecoration(
                  hintText: "What is your email?",
                errorText: createfail ? error : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                )
              ),

            ),
            TextFormField(
              controller: fullnameController,
              decoration: InputDecoration(
                hintText: "Type in a username (max 20 characters)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
              ),
              maxLength: 20,
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: "Type in a password (max 20 characters)",
                errorText: createfail ? error : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
              ),
              maxLength: 20,
            ),
            TextFormField(controller: password2controller,
            decoration: InputDecoration(
                hintText: "Type in a password (max 20 characters)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                )
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
                            if(_accountFormKey.currentState!.validate()){
                              String result = await FirebaseService().CreateUser(name: fullnameController.text,
                                  email: emailController.text, userType: dropdownValue!, password: passwordController.text);
                              if(!context.mounted){
                                return Navigator.of(context).pop();
                              } else {
                                  if (result == "success"){
                                      var url = "/${dropdownValue}home";
                                      Navigator.pushNamed(context, url);
                                  }  else {
                                    createfail = true;
                                    result = error;}
                            }}  else {createfail = true;}
                          },
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
