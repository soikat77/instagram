import 'package:flutter/material.dart';
import 'package:instagram/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// catching the database collection
final CollectionReference userRef =
    FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
  // _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: const Center(
        child: Text('Timeline'),
      ),
    );
  }
}
