import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/showcase_glass_theme.dart';
import '../widgets/app_default_layout.dart';
import '../widgets/app_header_bar.dart';

class EditProfile extends StatelessWidget {
  final String avatarPath;

  const EditProfile({super.key, required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    return AppDefaultLayout(
      body: Column(
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
                  child: SvgPicture.asset(avatarPath, fit: BoxFit.cover),
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
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),

          _buildProfileField(
            name: 'Name:',
            field: const GlassTextField(
              placeholder: '@NoNameUser',
              shape: LiquidRoundedSuperellipse(borderRadius: 25),
              placeholderStyle: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          _buildProfileField(
            name: 'Bio:',
            field: const GlassTextArea(
              placeholder: 'Tell about yourself...',
              shape: LiquidRoundedSuperellipse(borderRadius: 25),
              placeholderStyle: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          _buildProfileField(
            name: 'Link:',
            field: const GlassTextField(
              placeholder: 'https://example.com',
              shape: LiquidRoundedSuperellipse(borderRadius: 25),
              placeholderStyle: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Private data",
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),

          _buildProfileField(
            name: 'Birthday:',
            field: const DatePickerField(label: 'Birthday'),
          ),

          _buildProfileField(name: 'Sex:', field: const GenderSegmented()),
          Divider(color: Colors.grey, thickness: 0.5),

          SvgPicture.asset(
            'assets/images/Quixx.svg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),

      top: const AppHeaderBar(
        title: 'Edit profile',
        secondButtonTitle: 'Done',
        secondButtonWidth: double.infinity,
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
            style: const TextStyle(color: Colors.white, fontSize: 16),
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