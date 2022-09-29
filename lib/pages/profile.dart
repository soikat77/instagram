// import 'dart:js';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/edit_profile.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/post.dart';
import 'package:instagram/widgets/post_tile.dart';
import 'package:instagram/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  const Profile({super.key, required this.profileId});

  @override
  State<Profile> createState() => _ProfileState();
  // _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String? currentUserId = currentUser?.id;
  String postOrientation = "grid";
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePost();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .doc(widget.profileId)
        .collection('userPost')
        .orderBy('timastamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  /* ----------------------------- Profile Count Column ----------------------------- */
  Column buildCountColumn(String lebel, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: Text(
            lebel,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /* ----------------------------- Profile Button ----------------------------- */
  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId: currentUserId),
      ),
    );
  }

  Container buildButton({final String? text, final VoidCallback? function}) {
    return Container(
      width: 250.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: isFollowing ? Colors.grey : Colors.purple[900],
        borderRadius: BorderRadius.circular(7.0),
      ),
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(top: 10.0, left: 5.0),
      alignment: Alignment.center,
      child: TextButton(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16.0),
        ),
        onPressed: function,
        child: Text(
          text!,
          style: TextStyle(
            color: isFollowing ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing own profile --> should show edit profile
    bool isProfileowner = currentUserId == widget.profileId;
    if (isProfileowner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(text: "Unfollow", function: handleUnFollowUser);
    } else if (!isFollowing) {
      return buildButton(text: "Follow", function: handleFollowUser);
    }
  }

/* --------------------- current user unfollow other users --------------------- */
  handleUnFollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove current user from follower of other users
    // update the other user's follower collection
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        print(doc);
        doc.reference.delete();
      }
    });
    // remove those user in current user following collection
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        print(doc);
        doc.reference.delete();
      }
    });
    // delete activity feed notification
    feedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        print(doc);
        doc.reference.delete();
      }
    });
    print('$currentUserId unfollowing ${widget.profileId}');
  }

/* --------------------- current user follow other users --------------------- */
  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // make current user a follower of other users
    // update the other user's follower collection
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    // put those user in current user following collection
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activity feed notification
    feedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "userName": currentUser!.userName,
      "userId": currentUserId,
      "userProfileImg": currentUser!.photoUrl,
      "timestamp": timestamp,
      "mediaUrl": '',
      "postId": ''
    });
    print('$currentUserId started following ${widget.profileId}');
  }

/* ----------------------------- Profile Header ----------------------------- */
  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data as DocumentSnapshot);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  user.photoUrl == null
                      ? CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.purple[900],
                        )
                      : CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.purple[900],
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl!),
                        ),
                  Expanded(
                    flex: 1,
                    child: Column(children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildCountColumn("Posts", postCount),
                          buildCountColumn("Folllowers", followerCount),
                          buildCountColumn("Following", followingCount),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildProfileButton(),
                        ],
                      )
                    ]),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  user.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

/* ------------------------------ Profile Post ------------------------------ */
  buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/empty.svg', height: 360.0),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'No Post Found',
              style: TextStyle(
                color: Colors.black,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      for (var post in posts) {
        gridTiles.add(
          GridTile(
            child: PostTile(post: post),
          ),
        );
      }
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: const Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          iconSize: 24,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: const Icon(Icons.list_alt),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          iconSize: 28,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: [
          buildProfileHeader(),
          const Divider(
            height: 0.0,
          ),
          buildTogglePostOrientation(),
          buildProfilePost(),
        ],
      ),
    );
  }
}
