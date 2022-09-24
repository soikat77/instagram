import 'package:flutter/material.dart';
import 'package:instagram/widgets/header.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerID;
  final String postMediaUrl;

  const Comments({
    super.key,
    required this.postId,
    required this.postOwnerID,
    required this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerID: this.postOwnerID,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerID;
  final String postMediaUrl;

  CommentsState({
    required this.postId,
    required this.postOwnerID,
    required this.postMediaUrl,
  });

/* ------------------------------ Comments Area ----------------------------- */
  buildComments() {
    return const Text('comments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: [
          Expanded(child: buildComments()),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration:
                  const InputDecoration(labelText: "Write a Comment..."),
            ),
            trailing: OutlinedButton(
              onPressed: () => print('add coomment'),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Comment');
  }
}
