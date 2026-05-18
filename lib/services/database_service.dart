import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_program.dart';
import '../models/exercise.dart';
import '../widgets/widget_chart.dart';

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

  Future<List<ChartData>> getMonthlyStats(String userId, String monthName, int year) async {
    int monthNumber = _getMonthNumber(monthName);

    // Сюди інтегрується твій реальний запит до Firestore / SQLite.
    // Наприклад: await _firestore.collection('users').doc(userId).collection('workouts')...
    // Для прикладу ініціалізуємо пусті списки на 4 тижні:
    List<double> volumeValues = [0.0, 0.0, 0.0, 0.0];
    List<double> timeValues = [0.0, 0.0, 0.0, 0.0];
    List<double> repsValues = [0.0, 0.0, 0.0, 0.0];

    // Тут має бути цикл обробки твоїх завантажених тренувань. Наприклад:
    /*
    final workouts = await fetchWorkoutsForMonth(userId, monthNumber, year);
    for (var workout in workouts) {
      int weekIndex = _getWeekIndex(workout.date);
      volumeValues[weekIndex] += workout.volume;
      timeValues[weekIndex] += workout.durationInHours;
      repsValues[weekIndex] += workout.reps;
    }
    */

    // Тимчасові мокові дані для перевірки, які змінюються залежно від місяця:
    if (monthName == 'March') {
      volumeValues = [2800.0, 4200.0, 5533.0, 1700.0];
      timeValues = [75.6, 23.0, 46.2, 41.0];
      repsValues = [120.0, 274.0, 183.0, 620.0];
    } else {
      volumeValues = [1500.0, 3200.0, 2100.0, 4800.0];
      timeValues = [20.0, 45.5, 60.0, 30.2];
      repsValues = [300.0, 150.0, 420.0, 210.0];
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
}