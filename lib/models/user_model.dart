import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String avatarUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.avatarUrl,
  });

  // Фабричний конструктор для створення об'єкта з Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? data['nickname'] ?? 'Anonymous',
      avatarUrl: data['avatarUrl'] ?? 'https://i.pinimg.com/736x/4b/15/d5/4b15d58ce2edc5107c7372b00fcde1e8.jpg', // Твій дефолтний аватар
    );
  }

  // Конвертація в Map для збереження у Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'avatarUrl': avatarUrl,
    };
  }
}