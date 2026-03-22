import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:go_router/go_router.dart';
import '../theme/showcase_glass_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditProfile extends StatelessWidget {
  final String avatarPath;

  const EditProfile({super.key, required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090012),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 10,
                  right: 10,
                  bottom: 20,
                ),
                clipBehavior: Clip.none,
                child: AdaptiveLiquidGlassLayer(
                  settings: ShowcaseGlassTheme.profileButtonBig,
                  quality: ShowcaseGlassTheme.standardQuality,
                  child: Column(
                    spacing: 15,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: SvgPicture.asset(
                                avatarPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Change profile photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Text(
                        "Public profile data",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                        ),
                      ),

                      _buildProfileField(
                        name: 'Name:',
                        field: const GlassTextField(
                          placeholder: '@NoNameUser',
                          shape: LiquidRoundedSuperellipse(borderRadius: 25),
                          placeholderStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      _buildProfileField(
                        name: 'Bio:',
                        field: const GlassTextArea(
                          placeholder: 'Tell about yourself...',
                          shape: LiquidRoundedSuperellipse(borderRadius: 25),
                          placeholderStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      _buildProfileField(
                        name: 'Link:',
                        field: const GlassTextField(
                          placeholder: 'https://example.com',
                          shape: LiquidRoundedSuperellipse(borderRadius: 25),
                          placeholderStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Private data",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                        ),
                      ),

                      _buildProfileField(
                        name: 'Birthday:',
                        field: const DatePickerField(label: 'Birthday'),
                      ),

                      _buildProfileField(
                        name: 'Sex:',
                        field: const GenderSegmented(),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                      ),

                      SvgPicture.asset(
                        'lib/img/Quixx.svg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: AdaptiveLiquidGlassLayer(
                  quality: ShowcaseGlassTheme.premiumQuality,
                  settings: ShowcaseGlassTheme.profileButton,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GlassButton(
                          icon: Icons.arrow_back,
                          iconSize: 25,
                          width: 45,
                          height: 45,
                          onTap: () => context.pop(),
                        ),
                      ),
                      GlassButton.custom(
                        width: 120,
                        height: 45,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 25,
                        ),
                        onTap: () {},
                        child: const Text(
                          'Edit profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GlassButton.custom(
                          width: 70,
                          height: 45,
                          shape: const LiquidRoundedSuperellipse(
                            borderRadius: 25,
                          ),
                          onTap: () {},
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({required String name, required Widget field}) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: field),
      ],
    );
  }
}

class DatePickerField extends StatefulWidget {
  final String label;

  const DatePickerField({super.key, required this.label});

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: GlassTextField(
        readOnly: true,
        placeholder: _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : "Select date",
        shape: const LiquidRoundedSuperellipse(borderRadius: 25),
        placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
      ),
    );
  }
}

class GenderSegmented extends StatefulWidget {
  const GenderSegmented({super.key});

  @override
  State<GenderSegmented> createState() => _GenderSegmentedState();
}

class _GenderSegmentedState extends State<GenderSegmented> {
  int _selectedSegment = 0;
  final List<String> genders = ['Male', 'Female'];

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl(
      segments: genders,
      glassSettings: ShowcaseGlassTheme.profileButton,
      selectedIndex: _selectedSegment,
      onSegmentSelected: (index) {
        setState(() {
          _selectedSegment = index;
        });
      },
    );
  }
}
