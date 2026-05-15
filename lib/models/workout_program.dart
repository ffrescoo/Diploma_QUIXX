import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutProgram {
  final String id;
  final String title;
  final DateTime? createdAt;

  WorkoutProgram({
    required this.id,
    required this.title,
    this.createdAt,
  });

  // Фабричний конструктор для створення об'єкта з DocumentSnapshot Firestore
  factory WorkoutProgram.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutProgram(
      id: doc.id, // Автоматично отримуємо ID документа з бази даних
      title: data['title'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(), // Конвертуємо Timestamp у DateTime
    );
  }

  // Конвертація об'єкта Dart у формат Map для відправки у Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(), // Якщо null, Firebase сам виставить серверний час
    };
  }
}