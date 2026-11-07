import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_theme.dart';
import 'child_profile.dart';

class ChildSetupScreen extends StatefulWidget {
  const ChildSetupScreen({
    required this.onComplete,
    super.key,
  });

  final Future<void> Function(ChildProfile profile) onComplete;

  @override
  State<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends State<ChildSetupScreen> {
  static const _grades = [
    'Nursery',
    'LKG',
    'UKG',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
  ];

  final _nameController = TextEditingController();
  String? _selectedGrade;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedGrade == null || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onComplete(
        ChildProfile(name: name, grade: _selectedGrade!),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your profile could not be saved. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 154,
                  height: 154,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F5FF),
                    borderRadius: BorderRadius.circular(42),
                  ),
                  child: SvgPicture.asset(
                    'assets/characters/fox_buddy.svg',
                    semanticsLabel: 'Friendly fox buddy',
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text(
                  'Welcome to your play world!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Let’s make learning a little adventure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF71809B), fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'What should we call you?',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('child_name_field'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.face_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose your learning level',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'We’ll use this to suggest age-appropriate activities.',
                style: TextStyle(color: Color(0xFF71809B), fontSize: 12),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 9,
                runSpacing: 10,
                children: _grades.map((grade) {
                  final selected = _selectedGrade == grade;
                  return ChoiceChip(
                    key: Key('grade_$grade'),
                    label: Text(grade),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedGrade = grade),
                    selectedColor: const Color(0xFFE9E3FF),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected
                          ? AppTheme.violet
                          : const Color(0xFFE7EAF2),
                      width: selected ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.violet : AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 10,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  key: const Key('start_adventure_button'),
                  onPressed: _nameController.text.trim().isNotEmpty &&
                          _selectedGrade != null &&
                          !_isSaving
                      ? _continue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.violet,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD8DCE8),
                    elevation: 4,
                    shadowColor: AppTheme.violet.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Start my adventure',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Your profile stays on this device.',
                  style: TextStyle(color: Color(0xFF8993A8), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
