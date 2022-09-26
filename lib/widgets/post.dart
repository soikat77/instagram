// import 'dart:html';

import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/activity_feed.dart';
import 'package:instagram/pages/comments.dart';
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

  get userId => null;

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
  final currentUserId = currentUser?.id;
  late final String postId;
  late final String ownerID;
  late final String userName;
  late final String location;
  late final String description;
  late final String mediaUrl;
  bool showHeart = false;
  late bool isLiked;
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
            onTap: () => showProfile(context, profileId: user.id),
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

  handleLike() {
    bool isLiked = likes[currentUserId] == true;
    if (isLiked) {
      postRef
          .doc(ownerID)
          .collection('userPost')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      removeLikeFromFeed();

      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!isLiked) {
      postRef
          .doc(ownerID)
          .collection('userPost')
          .doc(postId)
          .update({'likes.$currentUserId': true});

      addLiketoFeed();

      setState(() {
        likeCount += 1;
        isLiked = false;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLiketoFeed() {
    // only from other user
    bool isNotPostOwner = currentUserId != ownerID;

    if (isNotPostOwner) {
      feedRef.doc(ownerID).collection("feedItems").doc(postId).set({
        "type": "like",
        "userName": currentUser!.userName,
        "userProfileImg": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromFeed() {
    // only other user
    bool isNotPostOwner = currentUserId != ownerID;

    if (isNotPostOwner) {
      feedRef
          .doc(ownerID)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.5, end: 1.5),
                  curve: Curves.bounceInOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                    scale: 1,
                    child: const Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.pink,
                    ),
                  ),
                )
              : const Text(''),
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
              onTap: handleLike,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20.0,
                color: Colors.pink,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40.0, right: 20.0),
            ),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerID: ownerID,
                mediaUrl: mediaUrl,
              ),
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
    isLiked = (likes[currentUserId] == true);
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

showComments(
  BuildContext context, {
  required String postId,
  required String ownerID,
  required String mediaUrl,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Comments(
          postId: postId,
          postOwnerID: ownerID,
          postMediaUrl: mediaUrl,
        );
      },
    ),
  );
}
