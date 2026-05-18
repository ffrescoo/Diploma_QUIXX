import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_program.dart';

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
  Future<void> addWorkoutProgram(String title, Map<String, Map<String, int>> exercisesData) async {
    if (uid.isEmpty) return;

    // 1. Створюємо головний документ програми всередині користувача
    final programRef = await _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });

    int index = 1;
    // 2. Записуємо кожну обрану вправу у вкладену підколекцію exercises цієї програми
    for (var entry in exercisesData.entries) {
      await programRef.collection('exercises').add({
        'name': entry.key,
        'sets': entry.value['sets'] ?? 4, // Записуємо введені підходи (або 4 за дефолтом)
        'reps': entry.value['reps'] ?? 10, // Записуємо введені повторення (або 10 за дефолтом)
        'order': index, // Порядковий номер вправи у списку
      });
      index++;
    }
  }
  // Отримання потоку вправ для конкретної програми тренувань
  Stream<QuerySnapshot> getProgramExercises(String programId) {
    if (uid.isEmpty) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('programs')
        .doc(programId)
        .collection('exercises')
        .orderBy('order', descending: false) // Сортуємо вправи за їхнім порядком
        .snapshots();
  }

  // Метод для збереження завершеного тренування в історію
  Future<void> saveCompletedWorkout({
    required String programTitle,
    required int totalSets,
    required int completedSets,
    required int durationInSeconds,
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
}