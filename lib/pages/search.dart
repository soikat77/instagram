import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
  // _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return const Text('Search');
  }
}

class UserResult extends StatelessWidget {
  const UserResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("User Result");
  }
}
