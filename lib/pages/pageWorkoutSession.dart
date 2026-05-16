import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'dart:async'; // Імпорт для роботи з Timer
import '../services/database_service.dart';
import '../theme/glass_theme.dart';
import '../widgets/appDefaultLayout.dart';

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

  // Локальна мапа для збереження стану чекбоксів
  final Map<String, List<bool>> _setsCheckedStatus = {};

  // Змінні для керування таймером
  Timer? _timer;
  Duration _workoutDuration = Duration.zero;
  bool _isWorkoutActive = false;
  late Stream<QuerySnapshot> _exercisesStream;

  @override
  void dispose() {
    _timer?.cancel(); // Обов'язково скасовуємо таймер при закритті екрана
    super.dispose();
  }

  // Функція для запуску/паузи таймера
  void _toggleWorkoutTimer() {
    setState(() {
      if (_isWorkoutActive) {
        // Якщо тренування вже активне — ставимо на паузу (або можна відразу викликати завершення)
        _isWorkoutActive = false;
        _timer?.cancel();
      } else {
        // Запуск тренування
        _isWorkoutActive = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _workoutDuration = Duration(seconds: _workoutDuration.inSeconds + 1);
          });
        });
      }
    });
  }

  // Форматування тривалості у вигляд ММ:СС або ГГ:ММ:СС
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  // Обчислення загального прогресу тренування (відсоток виконаних підходів)
  double _calculateTotalProgress() {
    int totalSets = 0;
    int completedSets = 0;

    _setsCheckedStatus.forEach((exerciseId, setsList) {
      totalSets += setsList.length;
      completedSets += setsList.where((set) => set == true).length;
    });

    if (totalSets == 0) return 0.0;
    return completedSets / totalSets;
  }

  // Функція завершення тренування з показом підсумкового вікна
  void _finishWorkout() {
    _timer?.cancel();
    final finalTime = _formatDuration(_workoutDuration);
    final double progressPercent = _calculateTotalProgress() * 100;

    int totalCompleted = 0;
    _setsCheckedStatus.forEach((_, list) {
      totalCompleted += list.where((item) => item == true).length;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Користувач має натиснути кнопку закриття
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Workout Completed! 🎉',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                'Program: ${widget.programTitle}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                'Duration: $finalTime',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                'Completed sets: $totalCompleted',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                'Success Rate: ${progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: progressPercent >= 80 ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Закриваємо діалог
                Navigator.pop(context);       // Повертаємося назад на вкладку тренувань
              },
              child: const Text(
                'Awesome',
                style: TextStyle(color: Color(0xFF6900FF), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
    // Ініціалізуємо потік один раз, щоб уникнути миготіння при setState
    _exercisesStream = _dbService.getProgramExercises(widget.programId);
  }

  @override
  Widget build(BuildContext context) {
    final double currentProgress = _calculateTotalProgress();

    return AppDefaultLayout(
      top: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
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
      topSpacing: 10,
      body: Column(
        spacing: 15,
        children: [
          // Панель Таймера та Кнопок керування
          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 12,
                children: [
                  // Відображення часу
                  Text(
                    _formatDuration(_workoutDuration),
                    style: TextStyle(
                      color: _isWorkoutActive ? Colors.greenAccent : Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: 1.5,
                    ),
                  ),

                  // Рядок із кнопками керування
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
                                _isWorkoutActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: _isWorkoutActive ? Colors.orangeAccent : Colors.greenAccent,
                                size: 24,
                              ),
                              Text(
                                _isWorkoutActive ? 'Pause' : 'Start',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Кнопка Завершити тренування (доступна лише якщо час більше 0)
                      if (_workoutDuration.inSeconds > 0)
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

          // Шкала прогресу активного тренування
          if (_workoutDuration.inSeconds > 0)
            GlassContainer(
              width: double.infinity,
              shape: const LiquidRoundedSuperellipse(borderRadius: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Workout Progress',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${(currentProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // Рендеримо горизонтальний прогрес-бар
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: currentProgress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6900FF)),
                        minHeight: 8,
                      ),
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

          // Стрім вправ із бази даних
          StreamBuilder<QuerySnapshot>(
            stream: _exercisesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading exercises', style: TextStyle(color: Colors.red)));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: CircularProgressIndicator(color: Colors.white24),
                  ),
                );
              }

              final exerciseDocs = snapshot.data?.docs ?? [];

              if (exerciseDocs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'No exercises added to this program yet.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                );
              }

              return Column(
                spacing: 15,
                children: exerciseDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String exerciseId = doc.id;
                  final String name = data['name'] ?? 'Unknown Exercise';

                  final int setsCount = data['sets'] ?? 4;
                  final int repsCount = data['reps'] ?? 10;

                  if (!_setsCheckedStatus.containsKey(exerciseId)) {
                    _setsCheckedStatus[exerciseId] = List.generate(setsCount, (_) => false);
                  }

                  return GlassContainer(
                    width: double.infinity,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6900FF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$setsCount sets x $repsCount reps',
                                  style: const TextStyle(color: Color(0xFFB080FF), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.white10, height: 1),
                          const SizedBox(height: 5),

                          Column(
                            children: List.generate(setsCount, (setIndex) {
                              final isChecked = _setsCheckedStatus[exerciseId]![setIndex];

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
                                  subtitle: Text(
                                    '$repsCount reps',
                                    style: TextStyle(color: isChecked ? Colors.white24 : Colors.white54, fontSize: 14),
                                  ),
                                  value: isChecked,
                                  activeColor: const Color(0xFF6900FF),
                                  checkColor: Colors.white,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (bool? newValue) {
                                    // Оновлюємо стан чекбоксу та відразу перераховуємо шкалу загального прогресу
                                    setState(() {
                                      _setsCheckedStatus[exerciseId]![setIndex] = newValue ?? false;
                                    });
                                  },
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}