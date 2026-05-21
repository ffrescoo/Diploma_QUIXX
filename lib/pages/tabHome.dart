import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../navigation/appRouter.dart';
import '../widgets/appDefaultLayout.dart';
import '../widgets/widgetPost.dart';
import '../services/user_session.dart';
import '../widgets/user_search_delegate.dart';
import '../widgets/widget_create_post.dart';
import '../services/database_service.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      top: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. ОНОВЛЕНА ЧАСТИНА: StreamBuilder для динамічного підвантаження аватара та нікнейму
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(DatabaseService().uid).snapshots(),
            builder: (context, snapshot) {
              String avatarUrl = 'assets/images/Avatar.svg';
              String nickname = UserSession.nickname;

              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data != null) {
                  avatarUrl = data['avatarUrl'] ?? avatarUrl;
                  nickname = data['username'] ?? data['nickname'] ?? nickname;
                }
              }

              Widget avatarWidget;
              if (avatarUrl.startsWith('http')) {
                avatarWidget = Image.network(avatarUrl, width: 26, height: 26, fit: BoxFit.cover);
              } else {
                avatarWidget = SvgPicture.asset(avatarUrl, width: 26, height: 26, fit: BoxFit.cover);
              }

              return IntrinsicWidth(
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
                        // Контейнер для скруглення аватара
                        Container(
                          width: 26,
                          height: 26,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: avatarWidget,
                        ),
                        Text(
                          nickname,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Row(
            spacing: 10,
            children: [
              GlassButton(
                icon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.white,
                ),
                width: 40,
                height: 40,
                onTap: () {
                  // Виклик пошукового делегату Flutter
                  showSearch(
                    context: context,
                    delegate: UserSearchDelegate(),
                  );
                },
              ),

              GlassButton(
                icon: const ImageIcon(
                  AssetImage('assets/images/plus.png'),
                  size: 20,
                ),
                width: 40,
                height: 40,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const CreatePostBottomSheet(),
                  );
                },
              ),

              GlassButton(
                icon: const ImageIcon(
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

      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getPostsStream(),
        builder: (context, snapshot) {
          // 1. Стан завантаження даних
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }

          // 2. Якщо сталася помилка
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: Text('Помилка завантаження стрічки', style: TextStyle(color: Colors.white)),
              ),
            );
          }

          // 3. Якщо постів ще немає
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: Text('Стрічка порожня. Створіть перший пост!', style: TextStyle(color: Colors.white)),
              ),
            );
          }

          // 4. Успішне отримання даних
          final posts = snapshot.data!.docs;

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final postDoc = posts[index];
              final postData = postDoc.data() as Map<String, dynamic>;

              return QuixxPost(
                postId: postDoc.id,
                authorId: postData['authorId'] ?? '',
                username: postData['username'] ?? 'Unknown',
                userImage: postData['userImage'] ?? 'https://i.pinimg.com/736x/4b/15/d5/4b15d58ce2edc5107c7372b00fcde1e8.jpg',
                postImage: postData['postImage'] ?? '',
                likes: postData['likes'] ?? 0,
                likedBy: postData['likedBy'] ?? [],
                description: postData['description'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}