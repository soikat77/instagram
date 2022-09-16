import 'package:flutter/material.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// catching the database collection
final CollectionReference userRef =
    FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    // createUser();
    // updateUser();
    // deleteUser();
    super.initState();
  }

// creating a new user
  createUser() {
    userRef.doc("abcdefg").set({
      "username": "Jeff",
      "postCount": 0,
      "isAdmin": false,
    });
  }

  // updating the user
  updateUser() async {
    final doc = await userRef.doc("abcdefg").get();
    if (doc.exists) {
      doc.reference.update({
        "username": "Jeff Bejos",
        "postCount": 0,
        "isAdmin": false,
      });
    }
  }

  // deliting a user
  deleteUser() async {
    final doc = await userRef.doc("abcdefg").get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children =
              snapshot.data!.docs.map((doc) => Text(doc['username'])).toList();
          return Center(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
