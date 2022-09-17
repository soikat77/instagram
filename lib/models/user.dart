import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String userName;
  final String email;
  final String? photoUrl;
  final String displayName;
  final String? bio;

  User({
    required this.id,
    required this.userName,
    required this.email,
    this.photoUrl,
    required this.displayName,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc["id"],
      userName: doc["username"],
      email: doc["email"],
      photoUrl: doc["photoUrl"],
      displayName: doc["displayName"],
      bio: doc["bio"],
    );
  }
}
