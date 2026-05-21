import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String avatarUrl;
  final String bio;
  final String link;
  final DateTime? birthday;
  final String sex;

  // ДОДАНО: Поля для одиниць виміру
  final int weightUnit; // 0 = kg, 1 = lbs
  final int distanceUnit; // 0 = km, 1 = miles
  final int measurementsUnit; // 0 = cm, 1 = in

  UserModel({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    this.bio = '',
    this.link = '',
    this.birthday,
    this.sex = 'Male',
    this.weightUnit = 0,
    this.distanceUnit = 0,
    this.measurementsUnit = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? data['nickname'] ?? 'Anonymous',
      avatarUrl: data['avatarUrl'] ?? 'assets/images/Avatar.svg',
      bio: data['bio'] ?? '',
      link: data['link'] ?? '',
      birthday: data['birthday'] != null ? (data['birthday'] as Timestamp).toDate() : null,
      sex: data['sex'] ?? 'Male',

      // БЕЗПЕЧНЕ зчитування int64 (конвертуємо через num)
      weightUnit: data['weightUnit'] != null ? (data['weightUnit'] as num).toInt() : 0,
      distanceUnit: data['distanceUnit'] != null ? (data['distanceUnit'] as num).toInt() : 0,
      measurementsUnit: data['measurementsUnit'] != null ? (data['measurementsUnit'] as num).toInt() : 0,
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
      // УВАГА: Ми навмисно прибрали звідси weightUnit, distanceUnit та measurementsUnit.
      // Тепер при редагуванні профілю вони не будуть випадково перезаписуватись нулями!
    };
  }
}