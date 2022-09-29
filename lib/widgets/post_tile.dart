import 'package:flutter/material.dart';
import 'package:instagram/pages/post_screen.dart';
import 'package:instagram/widgets/custom_image.dart';
import 'package:instagram/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          userId: post.ownerID,
          postId: post.postId,
          // postId: post.ownerID,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
