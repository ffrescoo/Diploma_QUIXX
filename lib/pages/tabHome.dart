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
        spacing: 12,
        children: [
          QuixxPost(
            username: 'Ronny_Coleman',
            userImage: 'https://i.pinimg.com/736x/4b/15/d5/4b15d58ce2edc5107c7372b00fcde1e8.jpg',
            postImage: 'https://i.pinimg.com/736x/78/1a/d5/781ad5a4b0fae1f84554143c8a30ee2e.jpg',
            likes: 4556566,
            description: 'The mind is the limit. As long as the mind can envision the fact that you can do something, you can do it.',
          ),

          QuixxPost(
            username: 'Kevin_Levrone',
            userImage: 'https://i.pinimg.com/736x/bd/24/94/bd24941d814b277ac86576e44ceeb667.jpg',
            postImage: 'https://i.pinimg.com/736x/18/06/76/18067698b402c66f29b48eec4f86afd1.jpg',
            likes: 653,
            description: 'Go BIG or go home',
          ),

          QuixxPost(
            username: 'Jason_Statham',
            userImage: 'https://i.pinimg.com/736x/b6/f4/d1/b6f4d198ae1bfb3b24283551e623246d.jpg',
            postImage: 'https://i.pinimg.com/736x/49/c8/c6/49c8c66dfcbd415c21cccd86b9c0b554.jpg',
            likes: 12735,
            description: "You need to work in such a way that when you're gone, your results are so massive and your impact so complex, that it requires at least two people to even begin cleaning up the magnificent mess you’ve left behind.",
          ),
        ],
      ),
      top: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IntrinsicWidth(
            child: GlassButton.custom(
              width: double.infinity,
              height: 40,
              shape: const LiquidRoundedSuperellipse(borderRadius: 20),
              onTap: () => context.push(AppRouter.profile),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Row(
                  spacing: 7,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Avatar.svg',
                      width: 26,
                      height: 26,
                    ),
                    const Text(
                      'UserName',
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
                icon: ImageIcon(
                  AssetImage('assets/images/plus.png'),
                  size: 20,
                ),
                width: 40,
                height: 40,
                onTap: () {},
              ),

              GlassButton(
                icon: ImageIcon(
                  AssetImage('assets/images/bell.png'),
                  size: 20,
                ),
                width: 40,
                height: 40,
                onTap: () => context.push(AppRouter.notificationsPage),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
