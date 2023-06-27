import 'package:flutter/material.dart';
import 'firebase_service.dart';

class addAccountForm extends StatefulWidget{
  const addAccountForm({super.key});

  State<addAccountForm> createState() => addFormState();
}

class addFormState extends State<addAccountForm>{
  final GlobalKey<FormState> _addAccountFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController schoolnameController = TextEditingController();
  TextEditingController studentnameController = TextEditingController();
  bool nameNotFound = false;
  bool notFound = false;
  bool notFound2 = false;
  String? selectedClass;


  Widget build(BuildContext context){
    double deviceHeight = MediaQuery.of(context).size.height;
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    if(currentRoute == "/addParents"){
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
    child: Form(
      key: _addAccountFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
        TextFormField(
        controller: emailController,
        decoration: InputDecoration(
            hintText: "Add by email",
            errorText: notFound ? "Not found" : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            )
        )),
          ElevatedButton(onPressed: () async {
            bool x = await FirebaseService().isParentEmailMatch(email: emailController.text);
            if (x) {emailController.clear();} else {setState(() {
              notFound = true;
            });}
          }, child: const Text("Add Parent By Email")),
        TextFormField(
          controller: fullnameController,
            decoration: InputDecoration(
                hintText: "Add by name",
                errorText: notFound2 ? "Not found" : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                )
            )
        ),
          FutureBuilder(future: FirebaseService().getParentNameMatches(name: fullnameController.text),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return Expanded(child: snapshot.data);
                  } else {return const Text("Awaiting results");}
              }),
        ElevatedButton(onPressed: () async {
            var y = await FirebaseService().getParentNameMatches(name: fullnameController.text);
            if (y!=null){} else{setState(() {
              notFound2 = true;
            });}
        }, child: const Text("Add Parent By Name"))
        ],
      ),
    ));}
    else if (currentRoute == "/addSchools"){
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
    child: Form(
      key: _addAccountFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: schoolnameController,
              decoration: InputDecoration(
                  hintText: "Add by name",
                  errorText: notFound2 ? "Not found" : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
              )
          ),
          ElevatedButton(onPressed: () async {
              bool end = await FirebaseService().addSchool(name: schoolnameController.text);
              if (end) { print("add successful");} else {setState(() {
                setState(() {
                  notFound2 = true;
                });
              });}
          }, child: const Text("Add school by name"))
        ],
      ),
    ));
    } else {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Form(
        key:_addAccountFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          FutureBuilder(future: FirebaseService().getTeacherClasses(uid: FirebaseService().auth.currentUser!.uid),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<DropdownMenuItem> dropdownItems = [];
            if(snapshot.data() != null){
              for (Map i in snapshot.data()){
                dropdownItems.add(
                  DropdownMenuItem(value: i["className"],child: Text(i["className"]),)
                );
              }
              return DropdownButtonFormField(
                value: selectedClass,
                items: dropdownItems,
                onChanged: (value) {setState(() {
                  selectedClass = value!;
                });},);
            } else {return const Text("No classes to add students to.");}
              }
          ),
          TextFormField(controller: studentnameController,
              decoration: InputDecoration(
                  hintText: "Type name of student",
                  errorText: nameNotFound ? "Not found" : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
              )
          ),
          ElevatedButton(onPressed: () {
            null;
          },
              child: const Text("Add student by name")),
          TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                  hintText: "Type name of student",
                  errorText: notFound ? "Not found" : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
              )
          ),
          ElevatedButton(onPressed: () {},
              child: const Text("Add student by email"))
        ],)
      ));
    }
  }
}

class addAccountsPage extends StatelessWidget {
  const addAccountsPage({super.key});

  Widget build(BuildContext context){
    double deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(child: Scaffold(
        appBar: AppBar(toolbarHeight: deviceHeight*0.1,
            title: const Image(image: AssetImage("assets/images/squarelogo-removebg-preview.png"))),
        body: const addAccountForm()
    ));
  }
}