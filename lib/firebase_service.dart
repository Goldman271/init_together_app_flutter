import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Map? currentUser;

  FirebaseService();

  Future<String> LoginUser(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        currentUser = await getUserData(uid: userCredential.user!.uid);
        String url = '/${currentUser!["userType"]}home';
        return url;
      } else {
        return "failure";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "user not found";
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user';
      } else {
        return e.code;
      }
    }
  }

  Future<String> CreateUser({required String name,
    required String email,
    required String userType,
    required String password}) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid;
      await _db.collection('users').doc(userId).set({
        "fullName": name,
        "email": email,
        "userType": userType,
      });
      if (userType == "student") {
        await _db.collection('students').doc(userId).set({
          "name": name,
          "email": email,
          "schools": [],
          "parents": [],
          "classes": [],
        });
      } else if (userType == 'parent') {
        await _db.collection('parents').doc(userId).set({
          "name": name,
          "email": email,
          "concerned": false,
          "students": [],
          "schools": [],
        });
      }
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.code;
      }
    }
  }

  Future<Map> getUserData({required String uid}) async {
    DocumentSnapshot _doc = await _db.collection('users').doc(uid).get();
    return _doc.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentData({required String uid}) async {
    DocumentSnapshot _doc = await _db.collection('students').doc(uid).get();
    return _doc.data() as Map<String, dynamic>;
  }

  Future<Map> getClassInfo({required DocumentReference path}) async {
    DocumentSnapshot _doc = await path.get();
    return _doc.data() as Map;
  }

  Future<Map> getTeacherContactInfo({required String teacher}) async {
    QuerySnapshot _doc = await _db.collection('teachers').where("name", isEqualTo: teacher).get();
    for (var snapshot in _doc.docs){
      return snapshot.data() as Map;
    }
    return {};
  }

  Future<List<List>> getStudentEvents({required String uid}) async {
    List eventsList = [];
    List assignmentsList = [];
    DocumentSnapshot studentInfo = await _db.collection("students").doc(uid).get();
    Map info = studentInfo.data() as Map;
    int tilesCount = 0;
    final time = DateTime.now();
    for (var i in info!["classes"]){
      Map events = await getClassInfo(path: i["accessEvents"]);
      for(var i in events["events"]){
            eventsList.add(i);
      }
      for (var i in events["assignments"]) {
        assignmentsList.add(i);
      }
    }
    for(var i in info!["schools"]){
      DocumentSnapshot schoolInfoSnapshot = await _db.collection("schools").doc(i).get();
      Map schoolInfo = schoolInfoSnapshot.data() as Map;
      for(var i in schoolInfo["events"]){
        eventsList.add(i);
      }
    }



    assignmentsList.sort((a,b) => a["deadline"].seconds.compareTo(b["deadline"].seconds));
    eventsList.sort((a,b) => a["time"].seconds.compareTo(b["time"].seconds));
    for(var i in assignmentsList) {
      i["deadline"] = i["deadline"].toDate().toString().split(".")[0];
    }
    for(var i in eventsList){
      i["time"] = i["time"].toDate().toString().split(".")[0];
    }

    List<List> masterList = [assignmentsList, eventsList];
    return masterList;
  }

  Future<bool> isParentEmailMatch({required String email}) async{
    QuerySnapshot findParents = await _db.collection('parents').where("email", isEqualTo: email).get();
    var studentInfo = await _db.collection("students").doc(auth.currentUser!.uid).get();
    if(findParents.docs != null){
      for(var snapshot in findParents.docs){
        var studentInfo = await _db.collection("students").doc(auth.currentUser!.uid).get();
        Map studentInfoMap = studentInfo.data() as Map;
        List parents = studentInfoMap["parents"];
        parents.add(snapshot["name"]);
        _db.collection("students").doc(auth.currentUser!.uid).update({"parents": parents});
      } return true;} else {return false;}
    }


  Future<Widget?> getParentNameMatches({required String name}) async {
    QuerySnapshot findParents = await _db.collection('parents').where("name", isEqualTo: name).get();
    List<Map> matches = [];
    if(findParents.docs != null){
      for(DocumentSnapshot snapshot in findParents.docs){
        Map snapshotData = snapshot.data() as Map;
        snapshotData["access"] = snapshot.reference;
        matches.add(snapshotData);
      }
      return ListView.builder(itemCount: matches.length > 5 ? 5: matches.length,
          itemBuilder: (BuildContext context, int index) {
              return ListTile(title: Text(matches[index]["name"]),
                subtitle: Text(matches[index]["email"]),
                onTap: () async {
                  var studentInfo = await _db.collection("students").doc(auth.currentUser!.uid).get();
                  Map studentInfoMap = studentInfo.data() as Map;
                  List parents = studentInfoMap["parents"];
                  parents.add(matches[index]["name"]);
                  _db.collection("students").doc(auth.currentUser!.uid).update({"parents": parents});
                  var parentData = await matches[index]["access"].get();
                  Map parentMap = parentData.data() as Map;
                  List students = parentMap["students"];
                  students.add({"name": studentInfoMap["name"], "access": _db.collection("students").doc(auth.currentUser!.uid)});
                  matches[index]["access"].update({"students": students});
                  Navigator.pop(context);
                },
              );});
    } else {return null;}
  }

  Future<bool> addSchool({required String name}) async {
    DocumentReference isMatch = _db.collection("schools").doc(name);
    if (isMatch.get() != null) {
      var studentInfo = await _db.collection("students").doc(auth.currentUser!.uid).get();
      Map studentInfoMap = studentInfo.data() as Map;
      List schools = studentInfoMap["schools"];
      schools.add(name);
      _db.collection("students").doc(auth.currentUser!.uid).update({"schools": schools});
      return true;
    } else {
      return false;
    }
    }

  Future<List<Map>> getTeacherClasses({required String uid}) async {
    Map teacherData = await getUserData(uid: uid);
    String teacherName = teacherData["fullName"];
    QuerySnapshot _doc = await _db.collection('classes').where("teacher", isEqualTo: teacherName).get();
    List<Map> classesList = [];
    for(var snapshot in _doc.docs) {
      Map x = snapshot.data() as Map;
      classesList.add(x);
    }

    return classesList;
  }

  Future<Widget?> getStudentMatches({required String studentName, required String classAdd}) async {
    Map TeacherInfo = await _db.collection("teachers").doc(auth.currentUser!.uid).get() as Map;
    List teacherSchools = TeacherInfo["schools"];
    QuerySnapshot studentInfoQuery = await _db.collection("students").where("name", isEqualTo: studentName)
        .where("schools", arrayContainsAny: teacherSchools).get();
    List<Map> matches = [];
    if(studentInfoQuery.docs != null){
      for(var snapshot in studentInfoQuery.docs){
        Map snapshotData = snapshot.data() as Map;
        matches.add(snapshotData);
      }
      return ListView.builder(itemCount: matches.length > 5 ? 5: matches.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(title: Text(matches[index]["name"]),
              subtitle: Text(matches[index]["email"]),
              onTap: () async {
                addStudentToClass(uid: auth.currentUser!.uid, studentName: matches[index]["name"], email: matches[index]["email"],
                    classToAdd: classAdd);
              },
            );});
    } else {return null;}
  }

  Future<bool> addStudentToClass({required String uid, required String studentName, required String email, required String classToAdd}) async{
    Map userInfo = await getUserData(uid: uid);
    QuerySnapshot classesList = await _db.collection("classes").where("className", isEqualTo: classToAdd).
    where("teacher", isEqualTo: userInfo["fullName"]).get();
    QuerySnapshot student = await _db.collection("students").where("name", isEqualTo: studentName).where("email", isEqualTo: email).get();
    for(var y in student.docs){
      Map y2 = y.data() as Map;
    for (DocumentSnapshot snapshot in classesList.docs){
      Map x = snapshot.data() as Map;
      y2["classes"].add(
        {
          "accessEvents": snapshot.reference,
          "className": x["className"],
          "teacher": x["teacher"]
        }
      );
      y.reference.update({"classes": y2});
      List newList = x!["students"];
      newList.add(studentName);
      _db.collection("classes").doc
        ("${x!["className"].replaceAll(" ", "").toLowerCase()}${x!["teacher"].replaceAll(" ", "").toLowerCase()}")
      .update({"students": newList});
      break;
    }}

  return true;
  }

  Future<Map> getParentInfo({required String uid}) async {
    DocumentSnapshot _doc = await _db.collection("parents").doc(uid).get();
    return _doc.data() as Map;
  }
}

