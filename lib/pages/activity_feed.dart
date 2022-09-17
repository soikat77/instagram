import 'package:flutter/material.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
  // _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return const Text('Activity Feed');
  }
}

class ActivityFeedItem extends StatelessWidget {
  const ActivityFeedItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Activity Feed Item');
  }
}
