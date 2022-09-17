import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  const Comments({super.key});

  @override
  CommentsState createState() => CommentsState();
}

class CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return const Text('Comments');
  }
}

class Comment extends StatelessWidget {
  const Comment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Comment');
  }
}
