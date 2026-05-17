import 'package:flutter/material.dart';
import '../widgets/appDefaultLayout.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../services/database_service.dart';
import '../models/workout_program.dart';
import 'pageWorkoutSession.dart';
import '../services/workout_session_manager.dart';

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  void _showCreateProgramDialog(BuildContext context, DatabaseService dbService) {
    final controller = TextEditingController();

    // Глобальний довідник вправ для вибору (прибрали порожні рядки)
    final List<String> availableExercises = [
      'Bench Press',
      'Squats',
      'Deadlift',
      'Pull-ups',
      'Bicep Curls',
      'Leg Press',
    ];

    // Нова структура: { 'Назва вправи': { 'sets': 4, 'reps': 10 } }
    final Map<String, Map<String, int>> selectedExercisesData = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Дозволяє bottom sheet відкриватися на більшу висоту та адаптуватися під клавіатуру
      backgroundColor: const Color(0xFF1E1B24), // Твоя базова темна палітра
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Padding(
              // Динамічний відступ знизу, щоб клавіатура не перекривала поле введення
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Індикатор свайпу (Кастомний Handlebar)
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      margin: const EdgeInsets.only(bottom:15),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Верхня панель: Назва екрану + Кнопка створення
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create New Program',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Color(0xFF6900FF), size: 30),
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            dbService.addWorkoutProgram(
                              controller.text.trim(),
                              selectedExercisesData, // Передаємо мапу з sets та reps
                            );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Місце для назви програми тренування
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter program name (e.g. Legs Day)',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6900FF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Select Exercises:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Скрол меню з вправами на вибір та налаштуванням підходів/повторень
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = availableExercises[index];
                        final isSelected = selectedExercisesData.containsKey(exercise);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF6900FF).withOpacity(0.15),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Color(0xFF6900FF),
                                  ),
                                ),
                                title: Text(
                                  exercise,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Checkbox(
                                  value: isSelected,
                                  activeColor: const Color(0xFF6900FF),
                                  checkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (bool? value) {
                                    setBottomSheetState(() {
                                      if (value == true) {
                                        // Задаємо дефолтні значення 4 підходи та 10 повторень при виборі
                                        selectedExercisesData[exercise] = {'sets': 4, 'reps': 10};
                                      } else {
                                        selectedExercisesData.remove(exercise);
                                      }
                                    });
                                  },
                                ),
                                onTap: () {
                                  setBottomSheetState(() {
                                    if (!isSelected) {
                                      selectedExercisesData[exercise] = {'sets': 4, 'reps': 10};
                                    } else {
                                      selectedExercisesData.remove(exercise);
                                    }
                                  });
                                },
                              ),

                              // Якщо вправа обрана — показуємо інпути для введення даних
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                  child: Row(
                                    children: [
                                      const Text('Sets:', style: TextStyle(color: Colors.white70)),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 45,
                                        child: TextFormField(
                                          initialValue: selectedExercisesData[exercise]?['sets'].toString(),
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6900FF))),
                                          ),
                                          onChanged: (val) {
                                            final parsed = int.tryParse(val) ?? 4;
                                            selectedExercisesData[exercise]?['sets'] = parsed;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      const Text('Reps:', style: TextStyle(color: Colors.white70)),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 45,
                                        child: TextFormField(
                                          initialValue: selectedExercisesData[exercise]?['reps'].toString(),
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6900FF))),
                                          ),
                                          onChanged: (val) {
                                            final parsed = int.tryParse(val) ?? 10;
                                            selectedExercisesData[exercise]?['reps'] = parsed;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProgramDialog(BuildContext context, DatabaseService dbService, String id, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Program Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter new name',
              hintStyle: TextStyle(color: Colors.white54),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6900FF))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await dbService.updateWorkoutProgram(id, controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Color(0xFF6900FF), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DatabaseService dbService, String id, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1B24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Program', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete "$title"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                await dbService.deleteWorkoutProgram(id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final sessionManager = WorkoutSessionManager();
    return AppDefaultLayout(
      body: Column(
        spacing: 15,
        children: [
          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: Row(
                children: [
                  ImageIcon(
                    AssetImage('assets/images/plus.png'),
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Start new training',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'Programs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: GlassButton.custom(
                          width: double.infinity,
                          height: 60,
                          settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 12,
                          ),
                          onTap: () => _showCreateProgramDialog(context, dbService),
                          child: const Text(
                            'Create new',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: GlassButton.custom(
                          width: double.infinity,
                          height: 60,
                          settings: ShowcaseGlassTheme.profileButtonWhiteLight,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 12,
                          ),
                          onTap: () {},
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          GlassContainer(
            width: double.infinity,
            shape: const LiquidRoundedSuperellipse(borderRadius: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text(
                    'My programs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  StreamBuilder<List<WorkoutProgram>>(
                    stream: dbService.workoutPrograms,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print("Firestore Error: ${snapshot.error}");
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Error loading programs', style: TextStyle(color: Colors.red)),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: CircularProgressIndicator(color: Colors.white24),
                          ),
                        );
                      }

                      final programs = snapshot.data ?? [];

                      if (programs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            'No programs found. Create one!',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                        );
                      }

                      // Рендеримо список програм, отриманих з Firestore
                      return Column(
                        spacing: 10,
                        children: programs.map((p) => programsSection(
                          context: context,
                          dbService: dbService,
                          id: p.id,
                          title: p.title,
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          ValueListenableBuilder<ActiveWorkoutProgress?>(
            valueListenable: sessionManager.activeWorkout,
            builder: (context, activeProgress, child) {
              if (activeProgress == null) {
                return GlassContainer(
                  width: double.infinity,
                  height: 80,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'No training started',
                          style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final double progressPercent = activeProgress.totalSets > 0
                  ? (activeProgress.completedSets / activeProgress.totalSets)
                  : 0.0;

              String twoDigits(int n) => n.toString().padLeft(2, '0');
              final minutes = twoDigits(activeProgress.duration.inMinutes.remainder(60));
              final seconds = twoDigits(activeProgress.duration.inSeconds.remainder(60));
              final durationString = "${twoDigits(activeProgress.duration.inHours)}:$minutes:$seconds";

              return GlassContainer(
                width: double.infinity,
                shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Workout',
                                style: TextStyle(color: Color(0xFFB080FF), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                activeProgress.programTitle,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            durationString,
                            style: TextStyle(
                              color: activeProgress.isPaused ? Colors.amberAccent : Colors.greenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.white60, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${activeProgress.currentExerciseName} • Set ${activeProgress.currentSetNumber}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${activeProgress.completedSets}/${activeProgress.totalSets} Sets',
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6900FF)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 80),
        ],

      ),
      top: const SizedBox(height: 0),
      topSpacing: 15,
    );
  }

  Widget programsSection({
    required BuildContext context,
    required DatabaseService dbService,
    required String id,
    required String title
  }) {
    return GlassContainer( //
      width: double.infinity, //
      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
      settings: ShowcaseGlassTheme.profileButtonWhiteLight,
      child: Padding( //
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold), //
                ),
                const Spacer(),


                PopupMenuButton<String>(
                  color: const Color(0xFF1E1B24),
                  icon: const ImageIcon(
                    AssetImage('assets/images/more.png'),
                    size: 20, //
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditProgramDialog(context, dbService, id, title);
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(context, dbService, id, title);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Rename', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GlassButton.custom(
              width: double.infinity,
              height: 45,
              settings: ShowcaseGlassTheme.profileButtonWhite,
              shape: const LiquidRoundedSuperellipse(borderRadius: 12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutSessionPage(
                      programId: id,
                      programTitle: title,
                    ),
                  ),
                );
              },
              child: const Text(
                'Start program',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500), //
              ),
            ),
          ],
        ),
      ),
    );
  }
}
