import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram/pages/profile.dart';
import 'package:instagram/pages/search.dart';
import 'package:instagram/pages/upload.dart';
import 'package:instagram/pages/timeline.dart';

import 'activity_feed.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuth = false; // setting not authenticated
  late PageController pageController; // Page Controler
  int pageIndex = 0; // first page

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user sign in
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      // hecking if there is an error to sign in
      onError: (err) {
        // print('Error signing in: $err');
      },
    );
    // Reauthenticated user when app is re-oppen
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    });
  }

  // checking if sign in or not the setting authenticated or not
  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      // print('User signed in!: $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  // vanish the controler
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // sign in or log in
  logIn() {
    googleSignIn.signIn();
  }

  // sign out or log out
  logOut() {
    googleSignIn.signOut();
  }

  // changing page
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  Scaffold buildAuthScreen() {
    // log out button
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)), // timeline
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active)), // Activity Feed
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 44.0,
          )), // upload
          BottomNavigationBarItem(icon: Icon(Icons.search)), //search
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)), // profile
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Instagram',
              style: TextStyle(
                fontFamily: "Back To School",
                fontSize: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18.0),
            // sign in button
            GestureDetector(
              onTap: logIn,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sign_in.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
