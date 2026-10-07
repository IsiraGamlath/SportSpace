import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'manager/manager_main_screen.dart';
import 'tertiary/home_view.dart';

class GoogleRoleSelecterScreen extends StatefulWidget {
  const GoogleRoleSelecterScreen({super.key});

  @override
  State<GoogleRoleSelecterScreen> createState() =>
      _GoogleRoleSelecterScreenState();
}

class _GoogleRoleSelecterScreenState extends State<GoogleRoleSelecterScreen> {
  int _selectedRole = 0;
  bool _isSigningIn = false;

  static const _roles = [
    (
      icon: Icons.person_outline,
      title: 'Player',
      description: 'Find, book and play at facilities near you.',
    ),
    (
      icon: Icons.grid_view_rounded,
      title: 'Facility Manager',
      description: 'Manage bookings, schedules and facility status.',
    ),
    (
      icon: Icons.explore_outlined,
      title: 'Community / Public User',
      description: 'Coach, parent or visitor browsing public events.',
    ),
  ];

  Future<void> _continueWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Google sign-in did not return a user account.');
      }

      final selectedRole = _roles[_selectedRole].title;
      final existingProfile = await ApiService.fetchUserProfile();
      final registeredRole = existingProfile?['role'] as String?;
      if (registeredRole != null && registeredRole.trim().isNotEmpty) {
        if (registeredRole != selectedRole) {
          _showSignInError(
            'This email is already registered as $registeredRole. '
            'Use another email for a $selectedRole account.',
          );
          await FirebaseAuth.instance.signOut();
          if (!kIsWeb) {
            await GoogleSignIn.instance.signOut();
          }
          return;
        }
      } else {
        await ApiService.syncGoogleProfile(
          fullName: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : user.email?.split('@').first ?? 'User',
          role: selectedRole,
        );
      }

      if (!mounted) return;
      final destination = _destinationForRole(registeredRole ?? selectedRole);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => destination),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      _showSignInError(error.message ?? 'Google sign-in failed.');
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        _showSignInError('Google sign-in was cancelled.');
      } else {
        _showSignInError('Unable to sign in with Google.');
      }
    } catch (_) {
      _showSignInError('Unable to sign in with Google.');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Widget _destinationForRole(String role) {
    switch (role) {
      case 'Facility Manager':
        return const ManagerMainScreen();
      case 'Community / Public User':
        return const TertiaryHomeView();
      default:
        return const HomeScreen();
    }
  }

  void _showSignInError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
              const SizedBox(height: 18),
              const Text(
                'Choose your role',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Select how you want to use SportSpace with your Google account.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(
                _roles.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RoleOption(
                    icon: _roles[index].icon,
                    title: _roles[index].title,
                    description: _roles[index].description,
                    selected: _selectedRole == index,
                    onTap: () => setState(() => _selectedRole = index),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 47,
                child: ElevatedButton(
                  onPressed: _isSigningIn ? null : _continueWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: _isSigningIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google.png',
                              width: 19,
                              height: 19,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
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

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryTeal : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEAF3F7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
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
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryTeal : AppColors.borderLight,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}
