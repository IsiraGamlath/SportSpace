import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/manager_text_field.dart';
import 'manager_main_screen.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'imal.fernando@sportspace.lk',
  );

  final TextEditingController _passwordController = TextEditingController(
    text: 'password',
  );

  bool _rememberMe = true;
  bool _hidePassword = true;

  void _signIn() {
    FocusScope.of(context).unfocus();

    // Navigate to Manager Dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerMainScreen(),
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset instructions sent to your email.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManagerColors.loginBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 20,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // SportSpace Logo in Left Top Corner (Matching Opening Screen)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/Sport Space logo.png',
                                width: 130,
                                height: 88,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.none,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0x332D91BA),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: ManagerColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'PORTAL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Flexible spacer to push the login content to the vertical center
                          const Spacer(),

                          const Text(
                            'Manager Portal',
                            style: TextStyle(
                              color: ManagerColors.primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Sign in to manage bookings, schedules and facility status.',
                            style: TextStyle(
                              color: ManagerColors.secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          const _FieldLabel('Email'),
                          const SizedBox(height: 8),

                          ManagerTextField(
                            controller: _emailController,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          const _FieldLabel('Password'),
                          const SizedBox(height: 8),

                          ManagerTextField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            suffix: IconButton(
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: ManagerColors.secondaryText,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _rememberMe
                                        ? ManagerColors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _rememberMe
                                          ? ManagerColors.green
                                          : ManagerColors.secondaryText,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: _rememberMe
                                      ? const Icon(
                                          Icons.check,
                                          size: 15,
                                          color: ManagerColors.white,
                                        )
                                      : null,
                                ),
                              ),

                              const SizedBox(width: 9),

                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  color: ManagerColors.secondaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                  foregroundColor: ManagerColors.green,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: ManagerColors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: ManagerColors.primaryButton,
                                foregroundColor: ManagerColors.white,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          // Bottom spacer to ensure perfect centering
                          const Spacer(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: ManagerColors.labelText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
