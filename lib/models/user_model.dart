import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String avatarUrl;
  final String bio;
  final String link;
  final DateTime? birthday;
  final String sex;

  UserModel({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    this.bio = '',
    this.link = '',
    this.birthday,
    this.sex = 'Male',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? data['nickname'] ?? 'Anonymous',
      avatarUrl: data['avatarUrl'] ?? 'assets/images/Avatar.svg', // Стандартне зображення
      bio: data['bio'] ?? '',
      link: data['link'] ?? '',
      birthday: data['birthday'] != null ? (data['birthday'] as Timestamp).toDate() : null,
      sex: data['sex'] ?? 'Male',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'link': link,
      'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
      'sex': sex,
    };
  }
}