import 'package:flutter/material.dart';
import 'firebase_service.dart';


class StudentNavDrawer extends StatefulWidget {
  const StudentNavDrawer({super.key});

  @override
  State<StudentNavDrawer> createState() => StudentNavState();
}

class StudentNavState extends State<StudentNavDrawer> {
  int selectedIndex = 0;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Student Home', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  child: Image.asset("assets/images/togetherwide.png"),
                  ),
              const ListTile(
                leading: Icon(Icons.home_filled),
                title: Text("Home"),
              ),
              const ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
                selectedTileColor: Colors.blue,
              ),
              const ListTile(
                leading: Icon(Icons.help_center),
                title: Text("Support"),
                selectedTileColor: Colors.blue,
              ),
              const ListTile(
                leading: Icon(Icons.book),
                title: Text("Classes"),
                selectedTileColor: Colors.blue,
              ),
              const ListTile(
                leading: Icon(Icons.people_alt),
                title: Text("Connect"),
                selectedTileColor: Colors.blue,
              ),
              const ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text("School Store"),
                selectedTileColor: Colors.blue,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                selectedTileColor: Colors.blue,
                onTap: () async {
                  await FirebaseService().auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pop();
                  } else {}
                  Navigator.popAndPushNamed(context, "/");
                },
              )
            ],
          )),
      body: const Text("Welcome student"),
    );
  }
}