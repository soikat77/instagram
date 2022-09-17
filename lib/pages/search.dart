import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
  // _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: const Icon(Icons.account_box),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => print('Cleared'),
          ),
        ),
      ),
    );
  }

  buildNoContent() {
    return Container(
      child: Center(
          child: ListView(
        shrinkWrap: true,
        children: [
          SvgPicture.asset('assets/images/User-research.svg', height: 300.0),
          const SizedBox(height: 36.0),
          const Text(
            'Find Users',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 54.0,
            ),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: buildSearchField(),
      body: buildNoContent(),
    );
  }
}

class UserResult extends StatelessWidget {
  const UserResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("User Result");
  }
}
