import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'studentClassScreen.dart';

class ParentHome extends StatelessWidget{
  const ParentHome({super.key});

  Widget build(BuildContext context){
    double deviceHeight = MediaQuery.of(context).size.height;
   return SafeArea(child: Scaffold(
    appBar: AppBar(
      toolbarHeight: deviceHeight*0.1,
      title: const Image(image: AssetImage("assets/images/squarelogo-removebg-preview.png")),
      actions: [IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/messages");
          },
          icon: Icon(Icons.message_outlined)),
        PopupMenuButton(itemBuilder: (BuildContext context) =>
        <PopupMenuEntry>[
          PopupMenuItem(
            child: Center(child: TextButton(
                child: const Text("Report a bug", style: TextStyle(color: Colors.black)),
                onPressed: () {Navigator.pushNamed(context, "/bugreporting");}
            )),
            onTap: () => Navigator.pushNamed(context, "/bugreporting"),
          ),
          PopupMenuItem(
            child: Center(child: TextButton(
                child: const Text("Help", style: TextStyle(color: Colors.black)),
                onPressed: () {Navigator.pushNamed(context, "/tutorial");}
            )),
            onTap: () => Navigator.pushNamed(context, "/tutorial"),
          )
        ])],
      centerTitle: true,
    ),
    )
   );}
}
class ParentHomepage extends StatefulWidget {
  const ParentHomepage({super.key});

  @override
  State<ParentHomepage> createState() => ParentHomepageState();
}

class ParentHomepageState extends State<ParentHomepage> {


  @override
  Widget build(BuildContext context){
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Center(child: Column(
      children: [FutureBuilder(future: FirebaseService().getParentInfo(uid: FirebaseService().auth.currentUser!.uid),
          builder: (BuildContext context, AsyncSnapshot snapshot){
          List<Widget> students = [Text("Your students:")];
          for (var i in snapshot.data()){
            students.add(Container(
              padding: const EdgeInsets.all(7.5),
              color: const Color(0xFFb2d8f7),
              child: Column(
                children: [
                  const Icon(Icons.person),
                  Text(i, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),)
                ],
              ),
            ));
          }
          return Row(children: students);
          }), ],
    ),);
  }
}