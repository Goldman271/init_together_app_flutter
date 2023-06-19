# init_together_app

FBLA Mobile App Dev Project

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Widget showSchools(x) {
      List<Widget> containers = [];
      for (var i in x["schools"]) {
        containers.add(Container(
          color: Colors.lightBlueAccent,
          child: Column(
            children: [
              const Icon(Icons.school),
              Text(i)
            ],
          ),
        ));
      }
      if(containers.isEmpty){return Container(
          color: Colors.lightBlueAccent,
          child: Row(
            children: [const Text("Add a school"), IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {Navigator.pushNamed(context, "/addSchools");
              },)
          ]));} else{for (var x in containers){
        return x;
      }}
      return Text("No schools joined.");
    }