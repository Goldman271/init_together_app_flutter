import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'studentHome.dart';

class StudentClassView extends StatelessWidget {
  const StudentClassView({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        toolbarHeight: deviceHeight*0.1,
        title: const Image(image: AssetImage("assets/images/squarelogo-removebg-preview.png")),
        actions: [IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/messages");
          },
          icon: const Icon(Icons.message_outlined))],
      ),
      drawer: const StudentNavDrawer(highlightIndex: 3),
      body: const StudentClassesInfo(),
    ));
  }

}

class StudentClassesInfo extends StatefulWidget{
  const StudentClassesInfo({super.key});

  @override
  State<StudentClassesInfo> createState() => StudentClassesInfoState();
}

class StudentClassesInfoState extends State<StudentClassesInfo> {

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Center(child: Column(children: [const Text("Your Classes", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 27)),
      FutureBuilder(future: FirebaseService().getStudentData(uid: FirebaseService().auth.currentUser!.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          List<Widget> classeslist = [];
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasData){
              List<Widget> classesList2 = [];
              for(var i in snapshot.data["classes"]){
                classesList2.add(ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(i["className"]),
                  subtitle: Text(i["teacher"]),
                  onTap: () async{
                    Map classinfo = await FirebaseService().getClassInfo(path: i["accessEvents"]);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => ClassDetailScreen(classInfo: classinfo)));},
                ));
              }
              classeslist = classesList2;
            } else if (snapshot.hasError) {
              classeslist = [Text("Error loading classes")];
            } else {classeslist = [const Text("It looks like you haven't been added to any classes yet.")];}
          } else {
            classeslist = [const CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: deviceHeight*0.05),
                child: const Text('Awaiting result...'),
              )];
          }
          return Expanded(child: ListView(children: classeslist));
        })],));
  }

}

class ClassDetailScreen extends StatelessWidget {
  final Map? classInfo;
  const ClassDetailScreen({super.key, this.classInfo});
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    List<Widget> tiles = [];
    List<Widget> eventTiles = [];
    List classAssignments = classInfo!["assignments"];
    classAssignments.sort((a,b) => a["deadline"].seconds.compareTo(b["deadline"].seconds));
    for (var i in classAssignments){
      tiles.add(ListTile(title: Text(i["name"]), subtitle: Text("Due ${i["deadline"].toDate().toString().split(".")[0]}"),));
    }

    List classEvents = classInfo!["events"];
    classEvents.sort((a,b) => a["time"].seconds.compareTo(b["time"].seconds));
    for(var i in classEvents) {
      eventTiles.add(ExpansionTile(controlAffinity: ListTileControlAffinity.trailing,
       title: Center(child: Text(i["name"])), subtitle: Text(i["time"].toDate().toString().split(".")[0]), children: [Text(i["description"])],));
    }

      return SafeArea(child: Scaffold(
        appBar: AppBar(
          toolbarHeight: deviceHeight*0.1,
          title: const Image(image: AssetImage("assets/images/squarelogo-removebg-preview.png")),
          actions: [IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/messages");
              },
              icon: const Icon(Icons.message_outlined))],
        ),
          drawer: const StudentNavDrawer(highlightIndex: 3),
          body: Container(
          padding: EdgeInsets.only(top: deviceHeight*0.04, left: deviceWidth*0.05, right: deviceWidth*0.05, bottom: deviceWidth*0.03),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Row(children: [SizedBox(
            width: 0.45*deviceWidth,
            height: 0.7*deviceHeight,
            child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [const Text("Your assignments"), Divider(height: 0.05*deviceHeight, thickness: 1.5), Expanded(child: ListView(children: tiles))])
          ),
          SizedBox(width: 0.45*deviceWidth,
            height: 0.7*deviceHeight,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Upcoming events"), Divider(height: 0.05*deviceHeight, thickness: 1.5), Expanded(child: ListView(children: eventTiles))])
          )]),
          Expanded(child: Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), color: Theme.of(context).colorScheme.surfaceVariant, child: SizedBox(height: deviceHeight*0.2, child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Teacher Info:"), Text(classInfo!["teacher"]),
          FutureBuilder(future: FirebaseService().getTeacherContactInfo(teacher: classInfo!["teacher"]), builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<Widget> info = [];
            if (snapshot.data != null){
            for (var i in snapshot.data["contactInfo"].keys){
                if (snapshot.data["contactInfo"][i] != ""){
                  info.add(ListTile(title: Text(i + ": " + snapshot.data["contactInfo"][i])));
                } else {continue;}
            }
            return Expanded(child: ListView(children: info));
          } else {return const Text("No contact information provided");}
          })]))
          ))])),
      ));
  }
}