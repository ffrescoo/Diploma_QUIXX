// lib/pages/pageWorkoutSession.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/workout_session_manager.dart';
import '../theme/glass_theme.dart';
import '../widgets/appBackground.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../models/exercise.dart';

class WorkoutSessionPage extends StatefulWidget {
  final String programId;
  final String programTitle;

  const WorkoutSessionPage({
    super.key,
    required this.programId,
    required this.programTitle,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  final DatabaseService _dbService = DatabaseService();
  final WorkoutSessionManager _sessionManager = WorkoutSessionManager();

  late Stream<List<Exercise>> _exercisesStream;
  Timer? _localUiUpdateTimer;

  List<Exercise> _currentLoadedExercises = [];
  @override
  void initState() {
    super.initState();

    // Ініціалізуємо потік один раз, щоб уникнути блимання списку
    _exercisesStream = _dbService.getProgramExercises(widget.programId);

    // Ініціалізуємо або підключаємось до існуючого тренування в синглтоні
    if (!_sessionManager.isCurrentProgramActive(widget.programId)) {
      _sessionManager.startWorkout(widget.programId, widget.programTitle);
    }

    // Запускаємо локальний таймер виключно для оновлення годинника на цьому екрані
    _localUiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _sessionManager.isTimerRunning()) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _localUiUpdateTimer?.cancel();
    super.dispose();
  }

  void _toggleWorkoutTimer() {
    setState(() {
      _sessionManager.toggleTimer();
    });
  }

  void _finishWorkout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Finish Workout 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to finish your workout and save results?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                // 1. Закриваємо діалогове вікно підтвердження
                Navigator.pop(dialogContext);

                // 2. Запускаємо збереження у ФОНОВОМУ режиМІ (прибираємо await перед методом)
                // Firestore сам додасть цей запис у внутрішню чергу і виконає його.
                _sessionManager.completeAndStopWorkout(_currentLoadedExercises).catchError((e) {
                  debugPrint("Background error saving workout: $e");
                });

                // 3. МИТТЄВО перенаправляємо користувача без очікування завантаження.
                // Використовуємо GoRouter, щоб уникнути чорного екрана
                if (mounted) {
                  context.go('/workout');
                }
              },
              child: const Text('Finish', style: TextStyle(color: Color(0xFF6900FF), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Форматування часу
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final duration = _sessionManager.getDuration();
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = twoDigits(duration.inHours);

    final bool isTimerRunning = _sessionManager.isTimerRunning();

    return Scaffold(
      backgroundColor: Colors.transparent, // Робимо Scaffold прозорим
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              spacing: 15,
              children: [
                const SizedBox(height: 5),
                // Верхня панель (Стрілочка назад + Назва програми)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context), // Вихід залишає тренування працювати у фоні
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.programTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Панель Таймера та Кнопок керування
                GlassContainer(
                  width: double.infinity,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      spacing: 12,
                      children: [
                        Text(
                          "$hours:$minutes:$seconds",
                          style: TextStyle(
                            color: isTimerRunning ? Colors.greenAccent : Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'SF Pro Display',
                            letterSpacing: 1.5,
                          ),
                        ),
                        Row(
                          spacing: 12,
                          children: [
                            // Кнопка Старт / Пауза
                            Expanded(
                              child: GlassButton.custom(
                                width: double.infinity,
                                height: 50,
                                settings: ShowcaseGlassTheme.profileButtonWhite,
                                shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                                onTap: _toggleWorkoutTimer,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      isTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: isTimerRunning ? Colors.orangeAccent : Colors.greenAccent,
                                      size: 24,
                                    ),
                                    Text(
                                      isTimerRunning ? 'Pause' : 'Start',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Кнопка Завершити
                            Expanded(
                              child: GlassButton.custom(
                                width: double.infinity,
                                height: 50,
                                settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                                shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                                onTap: _finishWorkout,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 6,
                                  children: [
                                    Icon(Icons.stop_rounded, color: Colors.redAccent, size: 24),
                                    Text(
                                      'Finish',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Exercises in this program:',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),

                // Список вправ із Firestore
                Expanded(
                  // 1. Змінюємо тип StreamBuilder на роботу зі списком об'єктів Exercise
                  child: StreamBuilder<List<Exercise>>(
                    stream: _exercisesStream, // Твій метод, який тепер повертає Stream<List<Exercise>>
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white24),
                        );
                      }

                      // snapshot.data тепер містить List<Exercise>
                      final exercisesList = snapshot.data ?? [];
                      _currentLoadedExercises = exercisesList;

                      if (exercisesList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No exercises added to this program yet.',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: exercisesList.length,
                        itemBuilder: (context, index) {
                          // Отримуємо об'єкт вправи з нашої моделі
                          final exercise = exercisesList[index];
                          final exerciseId = exercise.id;

                          // Перевіряємо чи є робоча вага
                          final bool hasWeight = exercise.weight != null && exercise.weight! > 0;

                          // Реєструємо назву та ініціалізуємо чекбокси через менеджер сесій
                          _sessionManager.registerExerciseName(exerciseId, exercise.name);

                          if (_sessionManager.setsCheckedStatus[exerciseId] == null) {
                            _sessionManager.setsCheckedStatus[exerciseId] = List<bool>.filled(exercise.sets, false);
                          }

                          final List<bool> currentSets = _sessionManager.setsCheckedStatus[exerciseId]!;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: GlassContainer(
                              width: double.infinity,
                              shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Заголовок вправи
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exercise.name,
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6900FF).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${exercise.sets} sets x ${exercise.reps} reps',
                                            style: const TextStyle(color: Color(0xFFB080FF), fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(color: Colors.white10, height: 1),
                                    const SizedBox(height: 5),

                                    // Список підходів (Кожен сет)
                                    Column(
                                      children: List.generate(exercise.sets, (setIndex) {
                                        final isChecked = currentSets[setIndex];

                                        return Theme(
                                          data: ThemeData(unselectedWidgetColor: Colors.white30),
                                          child: CheckboxListTile(
                                            title: Text(
                                              'Set ${setIndex + 1}',
                                              style: TextStyle(
                                                color: isChecked ? Colors.white38 : Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                                              ),
                                            ),

                                            // ОНОВЛЕНИЙ SUBTITLE: якщо є вага — показуємо "10 reps @ 80.0 kg", якщо немає — просто "10 reps"
                                            subtitle: Text(
                                              hasWeight
                                                  ? '${exercise.reps} reps @ ${exercise.weight} kg'
                                                  : '${exercise.reps} reps',
                                              style: TextStyle(
                                                color: isChecked
                                                    ? Colors.white24
                                                    : (hasWeight ? const Color(0xFFB080FF) : Colors.white54),
                                                fontSize: 14,
                                                fontWeight: hasWeight ? FontWeight.w500 : FontWeight.normal,
                                              ),
                                            ),
                                            value: isChecked,
                                            activeColor: const Color(0xFF6900FF),
                                            checkColor: Colors.white,
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            contentPadding: EdgeInsets.zero,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                _sessionManager.updateExerciseSetStatus(
                                                  exerciseId,
                                                  setIndex,
                                                  newValue ?? false,
                                                );
                                              });
                                            },
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}