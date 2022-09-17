import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/pages/home_page.dart';
import 'package:instagram/widgets/progress.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
  // _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultFuture;

  handleSubmit(String query) {
    Future<QuerySnapshot> users = userRef
        .where('displayName', isGreaterThanOrEqualTo: query.trim())
        .get();
    setState(() {
      searchResultFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: const Icon(Icons.account_box),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSubmit,
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          }
          return ListView(children: searchResults);
        });
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Center(
        child: ListView(
      shrinkWrap: true,
      children: [
        SvgPicture.asset(
          'assets/images/User-research.svg',
          height: orientation == Orientation.portrait ? 300.0 : 150.0,
        ),
        SizedBox(height: orientation == Orientation.portrait ? 36.0 : 12.0),
        Text(
          'Find Users',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            fontSize: orientation == Orientation.portrait ? 54.0 : 30.0,
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: buildSearchField(),
      body: searchResultFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  const UserResult(this.user, {super.key});
  // const UserResult({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: user.photoUrl == null
                  ? CircleAvatar(
                      backgroundColor: Colors.purple[900],
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.purple[900],
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl!),
                    ),
              title: Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.userName,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
