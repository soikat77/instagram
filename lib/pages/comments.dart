import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        for (var doc in snapshot.data!.docs) {
          comments.add(Comment.fromDocument(doc));
        }
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.doc(postId).collection('comments').add({
      "userName": currentUser!.userName,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUser!.photoUrl,
      "userId": currentUser!.id,
    });

    // only other user
    bool isNotPostOwner = postOwnerID != currentUser!.id;

    if (isNotPostOwner) {
      feedRef.doc(postOwnerID).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "userName": currentUser!.userName,
        "userProfileImg": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": postMediaUrl,
        "timestamp": timestamp,
      });
    }
    commentController.clear();
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
              onPressed: addComment,
              child: const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String userName;
  final String userId;
  final String? avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment(
      {super.key,
      required this.userName,
      required this.userId,
      required this.avatarUrl,
      required this.comment,
      required this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      userName: doc['userName'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: avatarUrl == null
              ? CircleAvatar(
                  backgroundColor: Colors.purple[900],
                )
              : CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(avatarUrl!),
                ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}
