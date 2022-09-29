// import 'dart:io';
// import 'dart:js';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/pages/post_screen.dart';
import 'package:instagram/pages/profile.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
  // _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await feedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    List<ActivityFeedItem> feedItems = [];
    for (var doc in snapshot.docs) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      print(doc.data());
    }
    return feedItems;
  }

  buildFeed() {
    return StreamBuilder(
      stream: feedRef
          .doc(currentUser!.id)
          .collection('feedItems')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<ActivityFeedItem> feedItems = [];
        for (var doc in snapshot.data!.docs) {
          feedItems.add(ActivityFeedItem.fromDocument(doc));
        }

        return ListView(children: feedItems);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: header(context, titleText: "Activity Feed"),
      body: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return buildFeed();
        },
      ),
    );
  }
}

late Widget mediaPreview;
late String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String userName;
  final String userId;
  final String type; // like, follow, comment
  final String mediaUrl;
  final String postId;
  final String? userProfileImg;
  // final String commentData;
  final Timestamp timestamp;

  const ActivityFeedItem({
    super.key,
    required this.userName,
    required this.userId,
    required this.type,
    required this.mediaUrl,
    required this.postId,
    required this.userProfileImg,
    // required this.commentData,
    required this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(QueryDocumentSnapshot doc) {
    return ActivityFeedItem(
      userName: doc['userName'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      // commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

// showProfile(BuildContext context, {required String profileId}) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => Profile(profileId: profileId)),
//   );
// }
  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          userId: currentUser!.id, // currentUser!.id or userId
          postId: postId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(mediaUrl),
              )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = const Text('');
    }

    if (type == 'like') {
      activityItemText = 'liked your post.';
    } else if (type == 'follow') {
      activityItemText = 'started following you.';
    } else if (type == 'comment') {
      activityItemText = 'comment your post';
    } else {
      activityItemText = 'Error: Unknown Type! $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' $activityItemText'),
                  ]),
            ),
          ),
          leading: userProfileImg == null
              ? CircleAvatar(
                  backgroundColor: Colors.purple[900],
                )
              : CircleAvatar(
                  backgroundColor: Colors.purple[900],
                  backgroundImage: CachedNetworkImageProvider(userProfileImg!),
                ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {required String profileId}) {
  print(profileId);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Profile(profileId: profileId)),
  );
}
