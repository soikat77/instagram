import 'package:flutter/material.dart';
import 'package:instagram/widgets/header.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  _TimelineState createState() => _TimelineState();
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
