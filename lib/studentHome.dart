import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';

class StudentHomepageInfo extends StatefulWidget{
  const StudentHomepageInfo({super.key});

  State<StudentHomepageInfo> createState() => StudentHomepageInfoState();
}

class StudentHomepageInfoState extends State<StudentHomepageInfo> {

  Widget build(BuildContext context){
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
  Future<Map> studentInfo = FirebaseService().getStudentData(uid: FirebaseService().auth.currentUser!.uid);
  return Column(
    children: [const Image(
      image: AssetImage("assets/images/defaultpfp.jpg")
    ),
      Row(
      children: [FutureBuilder(
          future: studentInfo,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<Widget> containers;
            String? name;
            if(snapshot.hasData){
              List<Widget> widglist = [];
              name = snapshot.data!["name"];
              for (var i in snapshot.data!["schools"]){
                widglist.add(Container(
                  color: const Color(0xFFb2d8f7),
                  child: Column(
                    children: [
                      const Icon(Icons.school),
                      Text(i)
                    ],
                  ),
                ));
              }
              containers = widglist;
            } else if (snapshot.hasError){
                  containers = [const Icon(Icons.error, color: Colors.red)];
            } else {
              containers = [const CircularProgressIndicator(),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),];
            }
            containers.insert(0, const Padding(
                padding: EdgeInsets.symmetric(horizontal:10.0),
                child: Text("Your Schools:")));
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 17.0),
                child: Column(
                    children: [Row(
                  children: [Padding(
                      padding: EdgeInsets.only(left: deviceWidth*0.06),
                      child: Text('$name', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20.2)))],
                ), const Divider(height: 17.5, color: Colors.black),Row(
                    children: containers)]));
          }
      )],
    )],
  );
  }
}


class StudentHomepage extends StatelessWidget {
  const StudentHomepage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
      drawer: const StudentNavDrawer(),
      body: const StudentHomepageInfo(),
    );
  }
}

class StudentNavDrawer extends StatefulWidget {
  const StudentNavDrawer({super.key});

  @override
  State<StudentNavDrawer> createState() => StudentNavState();
}

class StudentNavState extends State<StudentNavDrawer> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Image.asset("assets/images/togetherwide.png"),
            ),
            ListTile(
              leading: selectedIndex == 0
                  ? const Icon(Icons.home_filled)
                  : const Icon(Icons.home_outlined),
              title: const Text("Home"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 0;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 1
                  ? const Icon(Icons.person)
                  : const Icon(Icons.person_outline),
              title: const Text("Profile"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 1;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 2 ? const Icon(
                  Icons.help_center_rounded) : const Icon(
                  Icons.help_center_outlined),
              title: const Text("Support"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 2;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 3 ? const Icon(Icons.book) : const Icon(
                  Icons.book_outlined),
              title: const Text("Classes"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 3;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 4
                  ? const Icon(Icons.people_alt)
                  : const Icon(Icons.people_alt_outlined),
              title: const Text("Connect"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 4;
                  }
                  ),
            ),
            ListTile(
              leading: selectedIndex == 5
                  ? const Icon(Icons.shopping_cart)
                  : const Icon(Icons.shopping_cart_outlined),
              title: const Text("School Store"),
              onTap: () =>
                  setState(() {
                    selectedIndex = 5;
                  }
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await FirebaseService().auth.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                } else {}
                Navigator.popAndPushNamed(context, "/");
              },
            )
          ],
        ));
  }

}
