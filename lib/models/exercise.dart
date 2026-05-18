import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double? weight; // Опціональне поле для робочої ваги (null якщо не потрібна)
  final int order;

  // Конструктор
  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    required this.order,
  });

  // Фабричний конструктор для парсингу з Firestore DocumentSnapshot
  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Безпечне приведення типів (Firestore повертає num, який перетворюємо у double)
    double? parsedWeight;
    if (data['weight'] != null) {
      parsedWeight = (data['weight'] as num).toDouble();
    }

    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      sets: data['sets'] ?? 4,
      reps: data['reps'] ?? 10,
      weight: parsedWeight,
      order: data['order'] ?? 0,
    );
  }
}