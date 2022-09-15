import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) {
        print('User signed in!: $account');
        setState(
          () {
            isAuth = true;
          },
        );
      } else {
        setState(() {
          isAuth = false;
        });
      }
    });
  }

  logIn() {
    googleSignIn.signIn();
  }

  Widget buildAuthScreen() {
    return const Text('Authenticated');
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
