import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_program.dart';
import '../models/exercise.dart';
import '../widgets/widget_chart.dart';
import '../models/user_model.dart';
import '../services/user_session.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Отримання потоку (Stream) програм тренувань конкретного користувача з сортуванням
  Stream<List<WorkoutProgram>> get workoutPrograms {
    // Якщо користувач не авторизований, повертаємо порожній потік
    if (uid.isEmpty) return Stream.value([]);

    return _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .orderBy('createdAt', descending: true) // Сортуємо програми за часом створення
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => WorkoutProgram.fromFirestore(doc)) // Передаємо DocumentSnapshot замість Map
        .toList());
  }

  // Метод для додавання нової програми разом із обраними вправами та їхніми параметрами sets/reps
  Future<void> addWorkoutProgram(String title, Map<String, Map<String, dynamic>> exercisesData) async {
    if (uid.isEmpty) return; //

    // 1. Створюємо головний документ програми
    final programRef = await _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    }); //

    int index = 1; //

    // 2. Записуємо кожну вправу у підколекцію 'exercises'
    for (var entry in exercisesData.entries) {
      // Отримуємо значення ваги. Якщо користувач нічого не ввів або це вправа з власною вагою (0), запишемо null
      final weightValue = entry.value['weight'];

      await programRef.collection('exercises').add({
        'name': entry.key, //
        'sets': entry.value['sets'] ?? 4, //
        'reps': entry.value['reps'] ?? 10, //
        'order': index, //
        'weight': weightValue != null && weightValue > 0 ? weightValue : null, // ДОДАНО ПОЛЕ
      });
      index++; //
    }
  }
  // Отримання потоку вправ для конкретної програми тренувань
  Stream<List<Exercise>> getProgramExercises(String programId) {
    if (uid.isEmpty) return Stream.value([]); // Повертаємо порожній список, якщо uid порожній

    return _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .doc(programId)
        .collection('exercises')
        .orderBy('order', descending: false) //
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Exercise.fromFirestore(doc)) // Використовуємо фабричний конструктор
        .toList());
  }

  // Метод для збереження завершеного тренування в історію
  Future<void> saveCompletedWorkout({
    required String programTitle,
    required int totalSets,
    required int completedSets,
    required int durationInSeconds,
    double totalVolume = 0.0,
    int totalReps = 0,
  }) async {
    if (uid.isEmpty) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('history')
        .add({
      'title': programTitle,
      'totalSets': totalSets,
      'completedSets': completedSets,
      'durationInSeconds': durationInSeconds,
      'totalVolume' : totalVolume,
      'totalReps' : totalReps,
      'completedAt': FieldValue.serverTimestamp(), // Час завершення
    });
  }

  // Отримання потоку (Stream) завершених тренувань для сторінки профілю
  Stream<QuerySnapshot> getCompletedWorkouts() {
    if (uid.isEmpty) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('completedAt', descending: true) // Спочатку найновіші
        .snapshots();
  }

  Future<void> updateWorkoutProgram(String programId, String newTitle) async {
    if (uid.isEmpty) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .doc(programId)
        .update({
      'title': newTitle,
    });
  }
  Future<void> deleteWorkoutProgram(String programId) async {
    if (uid.isEmpty) return;

    final programRef = _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .doc(programId);

    // Спочатку отримуємо всі вправи з підколекції
    final exercisesSnapshot = await programRef.collection('exercises').get();

    // Створюємо пакет (WriteBatch) для видалення всього за один запит
    final batch = _db.batch();

    // Додаємо вправи до пакету на видалення
    for (var doc in exercisesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Додаємо саму програму до пакету
    batch.delete(programRef);

    // Виконуємо пакет
    await batch.commit();
  }

  // МІСЦЕ ДЛЯ ІНТЕГРАЦІЇ: Реальний Firestore-запит для статистики
  Future<List<ChartData>> getMonthlyStats(String userId, String monthName, int year) async {
    int monthNumber = _getMonthNumber(monthName);

    // Ініціалізуємо порожні масиви на 4 тижні
    List<double> volumeValues = [0.0, 0.0, 0.0, 0.0];
    List<double> timeValues = [0.0, 0.0, 0.0, 0.0];
    List<double> repsValues = [0.0, 0.0, 0.0, 0.0];

    // Розраховуємо часові межі (діапазон) для поточного місяця
    DateTime startOfMonth = DateTime(year, monthNumber, 1);
    DateTime endOfMonth = DateTime(year, monthNumber + 1, 1).subtract(const Duration(milliseconds: 1));

    try {
      // Робимо запит до колекції history конкретного користувача за обраний проміжок часу
      final querySnapshot = await _db
          .collection('users')
          .doc(userId.isNotEmpty ? userId : uid) // Якщо userId пустий, беремо uid поточного юзера
          .collection('history')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      // Обробляємо отримані документи тренувань
      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Отримуємо дату тренування з Timestamp
        final timestamp = data['completedAt'] as Timestamp?;
        if (timestamp == null) continue;
        DateTime workoutDate = timestamp.toDate();

        // Визначаємо індекс тижня (0, 1, 2 або 3)
        int weekIndex = _getWeekIndex(workoutDate);

        // Безпечно отримуємо та додаємо дані об'єму (Volume)
        double volume = 0.0;
        if (data['totalVolume'] != null) {
          volume = (data['totalVolume'] as num).toDouble();
        }
        volumeValues[weekIndex] += volume;

        // Безпечно отримуємо тривалість тренування та переводимо її у хвилини (Time)
        if (data['durationInSeconds'] != null) {
          double minutes = (data['durationInSeconds'] as num).toDouble() / 60.0;
          // Округлимо до 1 знаку після коми для гарного відображення на графіку
          timeValues[weekIndex] += double.parse(minutes.toStringAsFixed(1));
        }

        // Безпечно отримуємо та додаємо кількість повторень (Reps)
        int reps = 0;
        if (data['totalReps'] != null) {
          reps = (data['totalReps'] as num).toInt();
        }
        repsValues[weekIndex] += reps.toDouble();
      }
    } catch (e) {
      print("Помилка при завантаженні щомісячної статистики: $e");
      // У разі помилки повертаються нульові масиви, щоб додаток не падав
    }

    return [
      ChartData(title: "Volume", unitType: "volume", values: volumeValues),
      ChartData(title: "Time", unitType: "time", values: timeValues),
      ChartData(title: "Reps", unitType: "reps", values: repsValues),
    ];
  }

  int _getMonthNumber(String monthName) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(monthName) + 1;
  }

  int _getWeekIndex(DateTime date) {
    int day = date.day;
    if (day <= 7) return 0;   // 1-й тиждень
    if (day <= 14) return 1;  // 2-й тиждень
    if (day <= 21) return 2;  // 3-й тиждень
    return 3;                 // 4-й тиждень (і залишок місяця)
  }

  // Метод для підписки на користувача
  Future<void> followUser(String targetUserId, String targetUsername, String targetAvatar) async {
    if (uid.isEmpty || targetUserId == uid) return;

    final batch = _db.batch();

    // 1. Додаємо targetUserId у підколекцію 'following' поточного користувача
    final followingRef = _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(targetUserId);
    batch.set(followingRef, {
      'username': targetUsername,
      'avatarUrl': targetAvatar,
      'followedAt': FieldValue.serverTimestamp(),
    });

    // 2. Додаємо поточного користувача (uid) у підколекцію 'followers' цільового користувача
    // Примітка: для ідеального відображення тут можна було б брати дані з UserSession
    final followerRef = _db
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(uid);
    batch.set(followerRef, {
      'followedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Метод для скасування підписки
  Future<void> unfollowUser(String targetUserId) async {
    if (uid.isEmpty) return;

    final batch = _db.batch();

    // 1. Видаляємо з 'following' поточного користувача
    final followingRef = _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(targetUserId);
    batch.delete(followingRef);

    // 2. Видаляємо з 'followers' цільового користувача
    final followerRef = _db
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(uid);
    batch.delete(followerRef);

    await batch.commit();
  }

  // Перевірка в реальному часі (через Stream), чи підписаний поточний користувач на targetUserId
  Stream<bool> isFollowingStream(String targetUserId) {
    if (uid.isEmpty) return Stream.value(false);

    return _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(targetUserId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Отримання списку ID користувачів, на яких підписаний поточний юзер (для майбутньої стрічки)
  Future<List<String>> getFollowingIds() async {
    if (uid.isEmpty) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
  // Отримання кількості тих, на кого підписаний користувач (Following)
  Stream<int> getFollowingCountStream(String userId) {
    return _db
        .collection('users')
        .doc(userId.isNotEmpty ? userId : uid)
        .collection('following')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Отримання кількості підписників користувача (Followers)
  Stream<int> getFollowersCountStream(String userId) {
    return _db
        .collection('users')
        .doc(userId.isNotEmpty ? userId : uid)
        .collection('followers')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
// Метод для пошуку користувачів за нікнеймом
  Future<List<UserModel>> searchUsersByNickname(String query) async {
    if (query.isEmpty) return [];

    // Припускаємо, що у вашій колекції 'users' є поле 'nickname' або 'username'
    // Використовуємо комбінацію пошуку від початкового рядка query до кінцевого діапазону символів \uf8ff
    final snapshot = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

// Метод для створення нового поста у глобальній стрічці
  Future<void> createPost({required String description, String? postImageUrl}) async {
    if (uid.isEmpty) return;

    await _db.collection('posts').add({
      'authorId': uid,
      'username': UserSession.nickname,
      // Якщо у вас буде додано поле аватара в UserSession, можна використовувати його.
      // Поки залишаємо дефолтне або порожнє, якщо воно не налаштоване глобально.
      'userImage': 'https://i.pinimg.com/736x/4b/15/d5/4b15d58ce2edc5107c7372b00fcde1e8.jpg',
      'postImage': postImageUrl ?? '',
      'likes': 0,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}