import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'slot_selection_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _finish(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SlotSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/Sport Space logo.png',
                    width: 128,
                    height: 87,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                  TextButton(
                    onPressed: () => _finish(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF91AEC6),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(40, 40),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Image.asset(
                'assets/onboarding_athlete.png',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.none,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 52),
              color: AppColors.darkNavy,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PageIndicator(active: true),
                      _PageIndicator(),
                      _PageIndicator(),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'Find a place to play',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Discover courts and grounds nearby, with real-time availability at every facility.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF91AEC6),
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton(
                      onPressed: () => _finish(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C8DB4),
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
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool active;

  const _PageIndicator({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 19 : 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: active ? AppColors.available : Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
