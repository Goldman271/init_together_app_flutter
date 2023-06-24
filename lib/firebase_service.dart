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
        });
      } else if (userType == 'parent') {
        await _db.collection('parents').doc(userId).set({
          "name": name,
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
      Map schoolInfo = await _db.collection("schools").doc(i).get() as Map;
      for(var i in schoolInfo["events"]){
        eventsList.add(i);
      }
    }

    assignmentsList.sort((a,b) => a["deadline"].seconds.compareTo(b["deadline"].seconds));
    eventsList.sort((a,b) => a["deadline"].seconds.compareTo(b["deadline"].seconds));
    List<List> masterList = [assignmentsList, eventsList];
    return masterList;
  }
}