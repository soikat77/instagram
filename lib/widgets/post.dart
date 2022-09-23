// import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/custom_image.dart';
import 'package:instagram/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerID;
  final String userName;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  const Post(
      {super.key,
      required this.postId,
      required this.ownerID,
      required this.userName,
      required this.location,
      required this.description,
      required this.mediaUrl,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerID: doc['ownerID'],
      userName: doc['userName'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if there is no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;

    // if the key is explicitly set o true, add likes counts
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  // @override
  // State<Post> createState() {
  //   return _PostState();
  // }

  @override
  State<Post> createState() => _PostState(
        postId: this.postId,
        ownerID: this.ownerID,
        userName: this.userName,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  late final String postId;
  late final String ownerID;
  late final String userName;
  late final String location;
  late final String description;
  late final String mediaUrl;
  int likeCount;
  Map likes;

  _PostState({
    required this.postId,
    required this.ownerID,
    required this.userName,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.likes,
    required this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerID).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data!);
        return ListTile(
          leading: user.photoUrl == null
              ? CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.purple[900],
                )
              : CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.purple[900],
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
                ),
          title: GestureDetector(
            onTap: () => print('Tapped'),
            child: Text(
              user.userName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => print('delete'),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print('liked'),
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            Text(
              "$likeCount likes",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0, right: 20.0),
            ),
            GestureDetector(
              onTap: () => print('like'),
              child: const Icon(
                Icons.favorite_border,
                size: 20.0,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0, right: 20.0),
            ),
            GestureDetector(
              onTap: () => print('comment'),
              child: Icon(
                Icons.chat,
                size: 20.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
