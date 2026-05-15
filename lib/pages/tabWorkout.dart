import 'package:flutter/material.dart';
import '../widgets/appDefaultLayout.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/glass_theme.dart';
import '../services/database_service.dart';
import '../models/workout_program.dart';

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  void _showCreateProgramDialog(BuildContext context, DatabaseService dbService) {
    final controller = TextEditingController();

    // Глобальний довідник вправ для вибору
    final List<String> availableExercises = [
      'Bench Press',
      'Squats',
      'Deadlift',
      'Pull-ups',
      'Bicep Curls',
      'Leg Press'
    ];

    // Список для збереження вибраних користувачем вправ
    final List<String> selectedExercises = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1B24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Create New Program', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter program name (e.g. Legs Day)',
                        hintStyle: TextStyle(color: Colors.white54),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6900FF)),
                        ),
                      ),
                    ),
                    // Використовуємо класичний SizedBox замість spacing, щоб уникнути помилок версій Flutter
                    const SizedBox(height: 20),
                    const Text(
                      'Select Exercises:',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = availableExercises[index];
                          final isSelected = selectedExercises.contains(exercise);

                          return CheckboxListTile(
                            title: Text(exercise, style: const TextStyle(color: Colors.white)),
                            value: isSelected,
                            activeColor: const Color(0xFF6900FF),
                            checkColor: Colors.white,
                            //controlType: ListTileControlType.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedExercises.add(exercise);
                                } else {
                                  selectedExercises.remove(exercise);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      // Тепер типи методів у сервісі та діалозі повністю збігаються (передаємо 2 аргументи)
                      dbService.addWorkoutProgram(
                        controller.text.trim(),
                        selectedExercises,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Color(0xFF6900FF), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
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
                        children: programs.map((p) => programsSection(title: p.title)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          GlassContainer(
            width: double.infinity,
            height: 80,
            shape: const LiquidRoundedSuperellipse(borderRadius: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'No training started',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],

      ),
      top: const SizedBox(height: 0),
      topSpacing: 15,
    );
  }

  Widget programsSection({required String title}) {
    return GlassContainer(
      width: double.infinity,
      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
      settings: ShowcaseGlassTheme.profileButtonWhiteLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ImageIcon(
                  AssetImage('assets/images/more.png'),
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),

            GlassButton.custom(
              width: double.infinity,
              height: 45,
              settings: ShowcaseGlassTheme.profileButtonWhite,
              shape: const LiquidRoundedSuperellipse(borderRadius: 12),
              onTap: () {},
              child: const Text(
                'Start program',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
