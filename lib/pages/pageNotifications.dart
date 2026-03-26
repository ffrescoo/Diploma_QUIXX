import 'package:flutter/material.dart';
import '../widgets/appDefaultLayout.dart';
import '../widgets/appBarTop.dart';
import '../widgets/widgetNotify.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
        spacing: 15,
        children: const [
          NotificationCard(
            title: 'New Follower',
            icon: Icons.person_add,
            body: 'Pulsar started following you.',
          ),
          NotificationCard(
            title: 'Unfollowed',
            icon: Icons.person_off,
            body: 'Dinis Parimud just unfollowed you.',
          ),
          NotificationCard(
            title: 'New Post',
            icon: Icons.post_add,
            body: 'Bazarchenko added a new post',
          ),
          NotificationCard(
            title: 'Liked your post',
            icon: Icons.thumb_up,
            body: 'Svetka liked your post.',
          ),
          NotificationCard(
            title: 'Liked your post',
            icon: Icons.thumb_up,
            body: 'artem_bogurskiy liked your post.',
          ),
          NotificationCard(
            title: 'Liked your post',
            icon: Icons.thumb_up,
            body: 'Slavko liked your post.',
          ),
          NotificationCard(
            title: 'Liked your post',
            icon: Icons.thumb_up,
            body: 'yyanaii liked your post.',
          ),
          NotificationCard(
            title: 'Liked your post',
            icon: Icons.thumb_up,
            body: 's.u.e.t.a_security liked your post.',
          ),
          NotificationCard(
            title: 'Welcome!',
            icon: Icons.celebration,
            body: 'Hi there! Welcome to our community!',
          ),
        ],
      ),

      top: const AppHeaderBar(
        title: 'Notifications',
        secondButtonTitle: 'Ok',
        secondButtonWidth: 45,
      ),
    );
  }
}