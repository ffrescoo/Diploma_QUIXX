import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/exercise.dart';

class ActiveWorkoutProgress {
  final String programId;
  final String programTitle;
  final int totalSets;
  final int completedSets;
  final int currentSetNumber;
  final String currentExerciseName;
  final Duration duration;
  final bool isPaused;

  ActiveWorkoutProgress({
    required this.programId,
    required this.programTitle,
    required this.totalSets,
    required this.completedSets,
    required this.currentSetNumber,
    required this.currentExerciseName,
    required this.duration,
    required this.isPaused,
  });
}

class WorkoutSessionManager {
  static final WorkoutSessionManager _instance = WorkoutSessionManager._internal();
  factory WorkoutSessionManager() => _instance;
  WorkoutSessionManager._internal();

  final ValueNotifier<ActiveWorkoutProgress?> activeWorkout = ValueNotifier<ActiveWorkoutProgress?>(null);

  // Глобальні змінні стану сесії, які не зникнуть при закритті екрана
  Timer? _globalTimer;
  Duration _currentDuration = Duration.zero;
  bool _isWorkoutActive = false;
  String _activeProgramId = '';
  String _activeProgramTitle = '';

  // Зберігаємо стан чекбоксів для вправ: {exerciseId: [set1, set2, ...]}
  final Map<String, List<bool>> setsCheckedStatus = {};
  // Зберігаємо назви вправ для відображення
  final Map<String, String> exerciseNames = {};

  void startWorkout(String programId, String title) {
    // Якщо запускається те саме тренування, просто ігноруємо, щоб не скинути прогрес
    if (activeWorkout.value != null && _activeProgramId == programId) {
      resumeWorkoutTimer();
      return;
    }

    _activeProgramId = programId;
    _activeProgramTitle = title;
    _currentDuration = Duration.zero;
    _isWorkoutActive = true;
    setsCheckedStatus.clear();
    exerciseNames.clear();

    _updateNotifier();
    _startTimer();
  }

  void _startTimer() {
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration = Duration(seconds: _currentDuration.inSeconds + 1);
      _updateNotifier();
    });
  }

  void pauseWorkoutTimer() {
    _isWorkoutActive = false;
    _globalTimer?.cancel();
    _updateNotifier();
  }

  void resumeWorkoutTimer() {
    if (!_isWorkoutActive && activeWorkout.value != null) {
      _isWorkoutActive = true;
      _startTimer();
    }
  }

  void toggleTimer() {
    if (_isWorkoutActive) {
      pauseWorkoutTimer();
    } else {
      resumeWorkoutTimer();
    }
  }

  void updateExerciseSetStatus(String exerciseId, int setIndex, bool isChecked) {
    if (setsCheckedStatus[exerciseId] != null) {
      setsCheckedStatus[exerciseId]![setIndex] = isChecked;
      _updateNotifier();
    }
  }

  void registerExerciseName(String exerciseId, String name) {
    exerciseNames[exerciseId] = name;
  }

  void _updateNotifier() {
    int totalSets = 0;
    int completedSets = 0;
    int currentSetNumber = 1;
    String currentExerciseName = 'Warm-up';
    bool foundActive = false;

    setsCheckedStatus.forEach((exerciseId, setsList) {
      totalSets += setsList.length;
      int completedInExercise = setsList.where((set) => set == true).length;
      completedSets += completedInExercise;

      if (!foundActive && completedInExercise < setsList.length) {
        foundActive = true;
        currentSetNumber = completedInExercise + 1;
        currentExerciseName = exerciseNames[exerciseId] ?? 'Exercise';
      }
    });

    activeWorkout.value = ActiveWorkoutProgress(
      programId: _activeProgramId,
      programTitle: _activeProgramTitle,
      totalSets: totalSets,
      completedSets: completedSets,
      currentSetNumber: currentSetNumber,
      currentExerciseName: currentExerciseName,
      duration: _currentDuration,
      isPaused: !_isWorkoutActive,
    );
  }

  void stopWorkout() {
    _globalTimer?.cancel();
    _globalTimer = null;
    _currentDuration = Duration.zero;
    _isWorkoutActive = false;
    _activeProgramId = '';
    _activeProgramTitle = '';
    setsCheckedStatus.clear();
    exerciseNames.clear();
    activeWorkout.value = null;
  }

  bool isCurrentProgramActive(String programId) {
    return _activeProgramId == programId;
  }

  bool isTimerRunning() => _isWorkoutActive;
  Duration getDuration() => _currentDuration;

  Future<void> completeAndStopWorkout(List<Exercise> exercisesList) async {
    final progress = activeWorkout.value;

    if (progress != null) {
      double totalVolume = 0.0;
      int totalRepsCount = 0;

      // Проходимо по списку завантажених вправ
      for (var exercise in exercisesList) {
        // Отримуємо список галочок для цієї вправи [true, false, true, ...]
        final checkedList = setsCheckedStatus[exercise.id] ?? [];

        // Перевіряємо кожен підхід
        for (int i = 0; i < checkedList.length; i++) {
          // Рахуємо дані ТІЛЬКИ якщо підхід виконано (стоїть галочка)
          if (checkedList[i] == true) {
            // Додаємо повторення
            totalRepsCount += exercise.reps;

            // Додаємо об'єм (вага * повторення). Якщо вага null, вважаємо за 0
            double weight = exercise.weight ?? 0.0;
            totalVolume += (exercise.reps * weight);
          }
        }
      }

      final DatabaseService dbService = DatabaseService();

      // Викликаємо метод збереження, передаючи розраховані Volume та Reps
      await dbService.saveCompletedWorkout(
        programTitle: progress.programTitle,
        totalSets: progress.totalSets,
        completedSets: progress.completedSets,
        durationInSeconds: progress.duration.inSeconds,
        totalVolume: totalVolume,     // ПЕРЕДАЄМО РОЗРАХОВАНИЙ ОБ'ЄМ
        totalReps: totalRepsCount,    // ПЕРЕДАЄМО РОЗРАХОВАНІ ПОВТОРЕННЯ
      );
    }

    // Тільки після успішного await чистимо стан
    _globalTimer?.cancel();
    _globalTimer = null;
    _currentDuration = Duration.zero;
    _isWorkoutActive = false;
    _activeProgramId = '';
    _activeProgramTitle = '';
    setsCheckedStatus.clear();
    exerciseNames.clear();
    activeWorkout.value = null;
  }
}