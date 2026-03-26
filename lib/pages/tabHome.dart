import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../navigation/appRouter.dart';
import '../widgets/appDefaultLayout.dart';
import '../widgets/widgetPost.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
        spacing: 20,
        children: [
          QuixxPost(
            username: 'ira_hqd',
            userImage: 'https://i.pinimg.com/736x/d0/d9/73/d0d973ae34ff95cd6a6ea9df4809a54b.jpg',
            postImage: 'https://i.pinimg.com/736x/b1/6b/ad/b16bad8ff9d2187a54fd3011957be762.jpg',
            likes: 23,
            description: 'Finally found some peace and quiet in the city. There is something magical about how the light falls on these old streets. Definitely my favorite spot now! ☕️🏙️',
          ),

          QuixxPost(
            username: 'john_doe',
            userImage: 'https://i.pinimg.com/736x/2f/13/ea/2f13eacacf156a6103078adb7102ad33.jpg',
            postImage: 'https://i.pinimg.com/1200x/db/c6/0c/dbc60caafe493357cb459ff3ac90188b.jpg',
            likes: 653,
            description: 'Golden hour hits different. 🌅✨',
          ),

          QuixxPost(
            username: 'dariis_n',
            userImage: 'https://i.pinimg.com/736x/ed/e3/84/ede3844c1acf4854f5416e06520b18b5.jpg',
            postImage: 'https://i.pinimg.com/736x/e1/6a/f0/e16af08e5884dc6d22784137b52b1602.jpg',
            likes: 1223,
            description: 'The journey of a thousand miles begins with a single step, but it is the small moments along the way that truly matter. 🌍 \n\nToday I realized that happiness isn’t a destination, it’s a way of traveling. Sometimes you just need to stop, take a deep breath, and appreciate everything you have right now. Can’t wait to see what’s around the next corner! 📸🚀 \n\n#traveler #mindset #vibe #exploration',
          ),
        ],
      ),
      top: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IntrinsicWidth(
            child: GlassButton.custom(
              width: double.infinity,
              height: 45,
              shape: const LiquidRoundedSuperellipse(borderRadius: 25),
              onTap: () => context.push(AppRouter.profile),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Avatar.svg',
                      width: 29,
                      height: 29,
                    ),
                    const Text(
                      '@NoNameUser',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Row(
            spacing: 10,
            children: [
              GlassButton(
                icon: Icon(Icons.add),
                iconSize: 25,
                width: 45,
                height: 45,
                onTap: () {},
              ),

              GlassButton(
                icon: Icon(Icons.notifications_rounded),
                iconSize: 25,
                width: 45,
                height: 45,
                onTap: () => context.push(AppRouter.notificationsPage),
              ),
            ],
          ),
        ],
      ),
    );
  }
}