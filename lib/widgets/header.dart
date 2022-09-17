import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, titleText, removeBackBtn = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackBtn ? false : true,
    title: Text(
      isAppTitle ? 'Instagram' : titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Back To School' : '',
        fontSize: isAppTitle ? 32 : 18,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.secondary,
  );
}
