import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instagram/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scafoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late final String userName;

  // submit the form
  submit() {
    final form = _formKey.currentState;
    // validate
    if (form!.validate()) {
      // save
      form.save();
      // display greetings
      SnackBar snackBar = SnackBar(content: Text("Welcome $userName"));
      // got to previous rout
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context, userName);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scafoldKey,
      appBar: header(context,
          titleText: "Set up your Profile", removeBackBtn: true),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 24.0),
                const Center(
                  child: Text(
                    'Create a username',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: TextFormField(
                    validator: ((value) {
                      if (value!.trim().length < 3 || value.isEmpty) {
                        return "Username is too short";
                      } else if (value.trim().length > 12) {
                        return "Username is too long";
                      } else {
                        return null;
                      }
                    }),
                    onSaved: (value) => userName = value!,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Username",
                      labelStyle: TextStyle(fontSize: 18.0),
                      hintText: "Username must be at least 3 characters",
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
