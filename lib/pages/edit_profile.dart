import 'dart:ffi' hide Size;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/pages/profile.dart';
import 'package:instagram/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String? currentUserId;
  const EditProfile({super.key, required this.currentUserId});

  @override
  State<EditProfile> createState() => _EditProfileState();
  // _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  late User user;
  bool _displayNameValid = true;
  bool _biovalid = true;

  @override
  Void? initState() {
    super.initState();
    getUser();
    return null;
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot doc = await userRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Display Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name is too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _biovalid ? null : "Bio is too long",
          ),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100 || bioController.text.isEmpty
          ? _biovalid = false
          : _biovalid = true;
    });

    if (_displayNameValid && _biovalid) {
      userRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text.trim(),
        "bio": bioController.text.trim(),
      });

      SnackBar snackBar =
          const SnackBar(content: Text('Profile Updated Successfully'));

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  logOut() async {
    await googleSignIn.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            // onPressed: () => Navigator.pop(context),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profile(profileId: widget.currentUserId),
              ),
            ),
            icon: const Icon(
              Icons.done,
              color: Colors.green,
              size: 32.0,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: user.photoUrl == null
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
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: buildDisplayNameField(),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: buildBioField(),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: updateProfileData,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purple[900],
                        minimumSize: const Size(88, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      child: const Text('Update Profile'),
                    ),
                    const SizedBox(height: 16.0),
                    OutlinedButton(
                      onPressed: logOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(88, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ).copyWith(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              );
                            }
                            return BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 0,
                            );
                          },
                        ),
                      ),
                      child: const Text('Log out'),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
