import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:init_together_app/firebase_service.dart';
import 'package:init_together_app/studentHome.dart';
import 'package:table_calendar/table_calendar.dart';


class Calendar extends StatefulWidget{
  const Calendar({super.key});

  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  List _selectedEvents = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  void _onDaySelected(DateTime day, DateTime focusedDay){
    setState(() {
      _focusedDay = day;
    });
  }
  Future<List> getEvents() async{
    Map userInfo = await FirebaseService().getUserData(uid: FirebaseService().auth.currentUser!.uid);
    String userType = userInfo["userType"];
    List assignments = [];
    List occurrences = [];
    List<List> events = [assignments, occurrences];
    if (userType == "student"){
      List<List> getEvents = await FirebaseService().getStudentEvents(uid: FirebaseService().auth.currentUser!.uid);
      if(getEvents[0].isNotEmpty){
      for(Map i in getEvents[0]){
          assignments.add(i);
      }
      if(getEvents[1].isNotEmpty){
      for (Map i in getEvents[1]){
        occurrences.add(i);
      }}
      } else {}} else if (userType == "parent") {
        for (Map i in userInfo["students"]){
           String ref = i["access"].id;
           List<List> getEvents = await FirebaseService().getStudentEvents(uid: ref);
           if(getEvents[0].isNotEmpty){
           for(Map i in getEvents[0]){
             assignments.add(i);
           }}
           if(getEvents[1].isNotEmpty){
           for (Map i in getEvents[1]){
             occurrences.add(i);
           }}
        }
      }

    return events;
  }

  List getEventsForDay({required List events, required DateTime day}){
      if(events[0]!=null){
    for (Map i in events[0]) {
        if(isSameDay(i["deadline"].toDate(), day)){
          _selectedEvents.add({
            "time": i["deadline"].toDate().toString().split(".")[0].split(" ")[1],
          "name": i["name"],
            "description": i["description"]
          });
        } else {continue;}
      }}
      if(events[1].isNotEmpty){
      for (Map i in events[1]) {
        _selectedEvents.add({
          "time": i["time"].split(".")[0].split(" ")[1],
          "name": i["name"],
          "description": i["description"]
        });
      }}

      return _selectedEvents;
}

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    return SafeArea(child: Scaffold(
        appBar: AppBar(
          toolbarHeight: deviceHeight * 0.1,
          title: const Image(image: AssetImage(
              "assets/images/squarelogo-removebg-preview.png")),
          actions: [IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/messages");
              },
              icon: Icon(Icons.message_outlined)),
            PopupMenuButton(itemBuilder: (BuildContext context) =>
            <PopupMenuEntry>[
              PopupMenuItem(
                child: Center(child: TextButton(
                    child: const Text(
                        "Report a bug", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/bugreporting");
                    }
                )),
                onTap: () => Navigator.pushNamed(context, "/bugreporting"),
              ),
              PopupMenuItem(
                child: Center(child: TextButton(
                    child: const Text(
                        "Help", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.pushNamed(context, "/tutorial");
                    }
                )),
                onTap: () => Navigator.pushNamed(context, "/tutorial"),
              )
            ])
          ],
          centerTitle: true,
        ),
        drawer: const StudentNavDrawer(highlightIndex: 1),
        body: FutureBuilder(future: CalendarContent(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
                return snapshot.data;
            }))
    );
  }


    Future<Widget> CalendarContent() async {
      List events = await getEvents();
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: TableCalendar(
            headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true),
            locale: "en_US",
            selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
            availableGestures: AvailableGestures.all,
            firstDay: DateTime.utc(2023, 6, 1),
            focusedDay: _focusedDay,
            lastDay: DateTime.utc(2030, 12, 31),
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) => getEventsForDay(events: events, day: day),
            ),
          );
    }

  }