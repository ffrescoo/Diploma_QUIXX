import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/showcase_glass_theme.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/notify_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090012),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      AdaptiveLiquidGlassLayer(
                        settings: ShowcaseGlassTheme.profileButtonBig,
                        quality: ShowcaseGlassTheme.standardQuality,
                        child: Column(
                          children: [
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
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppHeaderBar(
                  title: 'Notifications',
                  secondButtonTitle: 'Ok',
                  secondButtonWidth: 45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}