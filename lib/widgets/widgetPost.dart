import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:intl/intl.dart';
import '../theme/glass_theme.dart';
import '../services/database_service.dart';

class QuixxPost extends StatelessWidget {
  final String authorId;
  final String username;
  final String userImage;
  final String postImage;
  final int likes;
  final String description;

  const QuixxPost({
    super.key,
    required this.authorId,
    required this.username,
    required this.userImage,
    required this.postImage,
    required this.likes,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * (4 / 3);
        final double glassTop = imageHeight - 40;
        final compactFormatter = NumberFormat.compact();

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  postImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: glassTop),
                GlassContainer(
                  settings: ShowcaseGlassTheme.profileButtonDark,
                  width: double.infinity,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 7,
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundImage: NetworkImage(userImage),
                            ),
                            Expanded(
                              child: Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IntrinsicWidth(
                              child: GlassButton.custom(
                                settings: ShowcaseGlassTheme.profileButtonWhite,
                                width: double.infinity,
                                height: 26,
                                shape: const LiquidRoundedSuperellipse(borderRadius: 13),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 7),
                                  child: Row(
                                    spacing: 5,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const ImageIcon(
                                        AssetImage('assets/images/like.png'),
                                        size: 15,
                                      ),
                                      Text(
                                        compactFormatter.format(likes),
                                        style: const TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            StreamBuilder<bool>(
                              stream: dbService.isFollowingStream(authorId),
                              builder: (context, snapshot) {
                                final isFollowing = snapshot.data ?? false;

                                // Якщо пост належить самому користувачу, кнопку підписки не показуємо
                                if (authorId == dbService.uid) return const SizedBox.shrink();

                                return IntrinsicWidth(
                                  child: GlassButton.custom(
                                    settings: isFollowing
                                        ? ShowcaseGlassTheme.profileButtonDark // Інший стиль, якщо вже підписані
                                        : ShowcaseGlassTheme.profileButtonWhite,
                                    width: double.infinity,
                                    height: 26,
                                    shape: const LiquidRoundedSuperellipse(borderRadius: 13),
                                    onTap: () async {
                                      if (isFollowing) {
                                        await dbService.unfollowUser(authorId);
                                      } else {
                                        await dbService.followUser(authorId, username, userImage);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Row(
                                        spacing: 5,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!isFollowing) const ImageIcon(
                                            AssetImage('assets/images/follow.png'),
                                            size: 15,
                                          ),
                                          Text(
                                            isFollowing ? 'Unfollow' : 'Follow',
                                            style: const TextStyle(fontSize: 15, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          description,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}