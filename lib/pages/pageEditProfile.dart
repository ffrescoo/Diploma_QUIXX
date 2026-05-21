import 'dart:io';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/appDefaultLayout.dart';
import '../widgets/appBarTop.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  final String avatarPath;

  const EditProfile({super.key, this.avatarPath = 'assets/images/Avatar.svg'});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final DatabaseService _dbService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  File? _imageFile;
  String _currentAvatarUrl = 'assets/images/Avatar.svg';

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _linkController;

  DateTime? _selectedBirthday;
  String _selectedSex = 'Male';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _linkController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Завантаження даних з Firebase
  Future<void> _loadUserData() async {
    final userProfile = await _dbService.getUserProfile();
    if (userProfile != null) {
      setState(() {
        _nameController.text = userProfile.username;
        _bioController.text = userProfile.bio;
        _linkController.text = userProfile.link;
        _selectedBirthday = userProfile.birthday;
        _selectedSex = userProfile.sex;
        _currentAvatarUrl = userProfile.avatarUrl;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // Вибір фото з галереї
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Збереження даних
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    String avatarUrlToSave = _currentAvatarUrl;

    // Якщо вибрано нове фото, завантажуємо його на Cloudinary
    if (_imageFile != null) {
      final uploadedUrl = await _dbService.uploadImageToCloudinary(_imageFile!);
      if (uploadedUrl != null) {
        avatarUrlToSave = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Помилка завантаження фото')),
        );
      }
    }

    final updatedUser = UserModel(
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      username: _nameController.text.trim(),
      avatarUrl: avatarUrlToSave,
      bio: _bioController.text.trim(),
      link: _linkController.text.trim(),
      birthday: _selectedBirthday,
      sex: _selectedSex,
    );

    await _dbService.updateUserProfile(updatedUser);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профіль успішно оновлено!')),
      );
      Navigator.pop(context); // Повертаємось назад після збереження
    }
  }

  // Відмальовка аватарки (SVG, Мережа або Файл)
  Widget _buildAvatarImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_currentAvatarUrl.startsWith('http')) {
      return Image.network(_currentAvatarUrl, fit: BoxFit.cover);
    } else {
      return SvgPicture.asset(widget.avatarPath, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return AppDefaultLayout(
      top: AppHeaderBar(
        title: 'Edit profile',
        secondButtonTitle: _isSaving ? 'Saving...' : 'Done',
        secondButtonWidth: double.infinity,
        // Переконайтеся, що ваш AppHeaderBar підтримує колбек для другої кнопки
        // Якщо параметр називається інакше (напр. onSecondButtonTap), змініть його:
        onAction: _isSaving ? null : _saveProfile,
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
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
                      child: _buildAvatarImage(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
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
            ),

            const Text(
              "Public profile data",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),

            _buildProfileField(
              name: 'Name:',
              field: GlassTextField(
                controller: _nameController,
                placeholder: '@NoNameUser',
                shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            _buildProfileField(
              name: 'Bio:',
              field: GlassTextArea(
                controller: _bioController,
                placeholder: 'Tell about yourself...',
                shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            _buildProfileField(
              name: 'Link:',
              field: GlassTextField(
                controller: _linkController,
                placeholder: 'https://example.com',
                shape: const LiquidRoundedSuperellipse(borderRadius: 25),
                placeholderStyle: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Private data",
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),

            _buildProfileField(
              name: 'Birthday:',
              field: DatePickerField(
                initialDate: _selectedBirthday,
                onDateSelected: (date) {
                  setState(() {
                    _selectedBirthday = date;
                  });
                },
              ),
            ),

            _buildProfileField(
                name: 'Sex:',
                field: GenderSegmented(
                  initialGender: _selectedSex,
                  onGenderSelected: (gender) {
                    setState(() {
                      _selectedSex = gender;
                    });
                  },
                )
            ),

            const Divider(color: Colors.grey, thickness: 0.5),

            SvgPicture.asset(
              'assets/images/Quixx.svg',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 40),
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
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: field),
      ],
    );
  }
}

// ОНОВЛЕНИЙ DatePickerField
class DatePickerField extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerField({
    super.key,
    this.initialDate,
    required this.onDateSelected
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  // Синхронізація, якщо дані завантажились із затримкою
  @override
  void didUpdateWidget(covariant DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
          widget.onDateSelected(picked);
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

// ОНОВЛЕНИЙ GenderSegmented
class GenderSegmented extends StatefulWidget {
  final String initialGender;
  final ValueChanged<String> onGenderSelected;

  const GenderSegmented({
    super.key,
    required this.initialGender,
    required this.onGenderSelected
  });

  @override
  State<GenderSegmented> createState() => _GenderSegmentedState();
}

class _GenderSegmentedState extends State<GenderSegmented> {
  final List<String> genders = ['Male', 'Female'];
  late int _selectedSegment;

  @override
  void initState() {
    super.initState();
    _selectedSegment = genders.indexOf(widget.initialGender);
    if (_selectedSegment == -1) _selectedSegment = 0;
  }

  @override
  void didUpdateWidget(covariant GenderSegmented oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialGender != oldWidget.initialGender) {
      setState(() {
        _selectedSegment = genders.indexOf(widget.initialGender);
        if (_selectedSegment == -1) _selectedSegment = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassSegmentedControl(
      segments: genders,
      selectedIndex: _selectedSegment,
      onSegmentSelected: (index) {
        setState(() {
          _selectedSegment = index;
        });
        widget.onGenderSelected(genders[index]);
      },
    );
  }
}