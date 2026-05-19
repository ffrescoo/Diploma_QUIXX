import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserSearchDelegate extends SearchDelegate {
  final DatabaseService _databaseService = DatabaseService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
        hintStyle: TextStyle(color: Colors.white54),
      ),
    );
  }

  // Зміна тексту підказки в полі пошуку на англійську
  @override
  String get searchFieldLabel => 'Search users...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.trim().isEmpty) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Text(
            "Type a username to search...",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return FutureBuilder<List<UserModel>>(
      future: _databaseService.searchUsersByNickname(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.black87,
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.black87,
            child: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Container(
            color: Colors.black87,
            child: const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          );
        }

        return Container(
          color: Colors.black87,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final displayName = user.username;

              // Перевірка, чи це поточний користувач
              final isMe = user.uid == _databaseService.uid;

              return StreamBuilder<bool>(
                stream: _databaseService.isFollowingStream(user.uid),
                builder: (context, followingSnapshot) {
                  final isFollowing = followingSnapshot.data ?? false;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[700],
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? NetworkImage(user.avatarUrl)
                          : null,
                      child: user.avatarUrl.isEmpty && displayName.isNotEmpty
                          ? Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                          : null,
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    trailing: isMe
                        ? const Text(
                      "You",
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    )
                        : TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.transparent : Colors.blueAccent,
                        side: isFollowing ? const BorderSide(color: Colors.white38) : BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () async {
                        if (isFollowing) {
                          await _databaseService.unfollowUser(user.uid);
                        } else {
                          await _databaseService.followUser(
                            user.uid,
                            user.username,
                            user.avatarUrl,
                          );
                        }
                      },
                      child: Text(
                        isFollowing ? "Unfollow" : "Follow",
                        style: TextStyle(
                          color: isFollowing ? Colors.white70 : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Кастомна логіка переходу на профіль за потреби
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}