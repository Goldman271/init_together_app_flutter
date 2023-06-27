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


return SizedBox(height: 70, child: Column(children: [Expanded(child: ListView(shrinkWrap: true, children: tiles,))],));
tiles.add(ExpansionTile(
                    title: Text(i["name"]), subtitle: Text(i["time"]), controlAffinity: ListTileControlAffinity.trailing,
                    children: [Text(i["description"])],));

                    calendarBuilders: CalendarBuilders(
                                  dowBuilder: (context, day) {
                                    List<Widget> tiles = [];
                                    List eventsList = getEventsForDay(events: events, day: day);
                                    if(eventsList.isEmpty){return const Center(child: Text("No events to be shown"));} else{
                                    for(Map i in eventsList){
                                      tiles.add(Column(children: [Text(i["name"]), Text(i["time"]), Text(i["description"])],));
                                    }}
                                      return Row(children: tiles);

                                  }
                                ),

