import 'package:flutter/material.dart';
import 'package:instagram/widgets/custom_image.dart';
import 'package:instagram/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('post'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
