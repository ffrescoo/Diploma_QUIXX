import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/showcase_glass_theme.dart';

class QuixxPost extends StatelessWidget {
  final String username;
  final String userImage;
  final String postImage;
  final int likes;
  final String description;

  const QuixxPost({
    super.key,
    required this.username,
    required this.userImage,
    required this.postImage,
    required this.likes,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * (4 / 3);
        final double glassTop = imageHeight - 50;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
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
                  shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 5,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundImage: NetworkImage(userImage),
                            ),
                            Expanded(
                              child: Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IntrinsicWidth(
                              child: GlassButton.custom(
                                settings: ShowcaseGlassTheme.profileButtonBig,
                                width: double.infinity,
                                height: 30,
                                shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    spacing: 8,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.favorite_border, size: 20, color: Colors.white),
                                      Text(
                                        '$likes',
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IntrinsicWidth(
                              child: GlassButton.custom(
                                settings: ShowcaseGlassTheme.profileButtonBig,
                                width: double.infinity,
                                height: 30,
                                shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    spacing: 8,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add, size: 20, color: Colors.white),
                                      const Text(
                                        'Follow',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          description,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
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