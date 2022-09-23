// import 'dart:js';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/edit_profile.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/header.dart';
import 'package:instagram/widgets/post.dart';
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
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePost();
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
        color: Colors.purple[900],
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
          style: const TextStyle(
            color: Colors.white,
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
    }
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
                          buildCountColumn("Posts", 0),
                          buildCountColumn("Folllowers", 0),
                          buildCountColumn("Following", 0),
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

  buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    }
    return Column(
      children: posts,
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
          buildProfilePost(),
        ],
      ),
    );
  }
}
