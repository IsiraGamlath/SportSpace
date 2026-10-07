import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'google_role_selecter_screen.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finish(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RoleSelectionScreen()),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openFinalPage() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildPage(
              title: 'Find a place to play',
              description:
                  'Discover courts and grounds nearby, with real-time availability at every facility.',
              imagePath: 'assets/onboarding_athlete.png',
              onContinue: _nextPage,
              onSkip: _openFinalPage,
            ),
            _buildPage(
              title: 'Compare & choose with confidence',
              description:
                  'See ratings, amenities and prices side by side before you pick a facility.',
              imagePath: 'assets/onboarding_athlete2.png',
              onContinue: _nextPage,
              onSkip: _openFinalPage,
            ),
            _buildFinalPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String imagePath,
    required VoidCallback onContinue,
    required VoidCallback onSkip,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 700.0;
        final header = Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 128),
                  child: Image.asset(
                    'assets/Sport Space logo.png',
                    width: double.infinity,
                    height: 87,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF91AEC6),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(40, 40),
                ),
                child: const Text('Skip'),
              ),
            ],
          ),
        );
        final content = Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          color: AppColors.darkNavy,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PageIndicator(active: _currentPage == 0),
                  _PageIndicator(active: _currentPage == 1),
                  _PageIndicator(active: _currentPage == 2),
                ],
              ),
              const SizedBox(height: 17),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                  onPressed: onContinue,
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
        );
        final image = Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.none,
        );

        if (availableHeight < 300) {
          return SingleChildScrollView(
            child: Column(
              children: [
                header,
                SizedBox(height: 220, child: image),
                content,
              ],
            ),
          );
        }

        return SizedBox(
          height: availableHeight,
          child: Column(
            children: [
              header,
              Expanded(child: image),
              content,
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinalPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 700.0;
        final content = Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              SizedBox(height: height > 500 ? 115 : 28),
              Image.asset(
                'assets/Sport Space logo.png',
                width: 128,
                height: 87,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(height: 24),
              const Text(
                'Find a place\nto play',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Discover courts and grounds nearby,\n'
                'check real-time availability, and book\n'
                'with confidence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF91AEC6),
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
              if (height > 500) const Spacer() else const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PageIndicator(active: _currentPage == 0),
                  _PageIndicator(active: _currentPage == 1),
                  _PageIndicator(active: _currentPage == 2),
                ],
              ),
              const SizedBox(height: 22),
              _OnboardingButton(
                label: 'Get Started',
                onPressed: () => _finish(context),
              ),
              const SizedBox(height: 6),
              _OnboardingButton(
                label: 'Log In',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                ),
                outlined: true,
              ),
              const SizedBox(height: 10),
              const Text(
                'OR',
                style: TextStyle(color: Color(0xFF91AEC6), fontSize: 10),
              ),
              const SizedBox(height: 8),
              _OnboardingButton(
                label: 'Continue with Google',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const GoogleRoleSelecterScreen(),
                  ),
                ),
                google: true,
              ),
            ],
          ),
        );

        if (height < 500) {
          return SingleChildScrollView(child: content);
        }

        return SizedBox(height: height, child: content);
      },
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final bool google;

  const _OnboardingButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.google = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : Colors.white,
          foregroundColor: outlined ? Colors.white : AppColors.darkNavy,
          side: BorderSide(
            color: outlined ? const Color(0xFF91AEC6) : Colors.transparent,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (google) ...[
              Image.asset(
                'assets/google.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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
