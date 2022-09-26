import 'package:flutter/material.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/post.dart';
import 'package:instagram/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  const PostScreen({super.key, required this.userId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.doc(userId).collection('userPost').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data!);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
