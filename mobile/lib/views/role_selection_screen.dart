import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'registration_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _selectedRole = 0;

  void _continue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RegistrationScreen(
          role: _roleNames[_selectedRole],
        ),
      ),
    );
  }

  static const _roleNames = [
    'Player',
    'Facility Manager',
    'Community / Public User',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/Sport Space logo 2.png',
                width: 128,
                height: 70,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(height: 12),
              const Text(
                'How will you use SportSpace?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Choose the option that best describes you. You\ncan change this later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _RoleCard(
                icon: Icons.person_outline,
                title: 'Player',
                description: 'Find, book and play at facilities\nnear you.',
                selected: _selectedRole == 0,
                onTap: () => setState(() => _selectedRole = 0),
              ),
              const SizedBox(height: 10),
              _RoleCard(
                icon: Icons.grid_view_rounded,
                title: 'Facility Manager',
                description: 'Manage bookings, schedules\nand facility status.',
                selected: _selectedRole == 1,
                onTap: () => setState(() => _selectedRole = 1),
              ),
              const SizedBox(height: 10),
              _RoleCard(
                icon: Icons.explore_outlined,
                title: 'Community / Public User',
                description:
                    'Coach, parent or visitor\nbrowsing public events.',
                selected: _selectedRole == 2,
                onTap: () => setState(() => _selectedRole = 2),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 47,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? AppColors.primaryTeal : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEAF3F7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primaryTeal : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primaryTeal
                      : AppColors.borderLight,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 11)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
