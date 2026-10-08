import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'services/account_settings_service.dart';
import 'views/launch_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase for authentication and other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AccountSettingsService.loadDarkMode();

  // 3. Configure system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 4. Initialize Stripe with your Publishable Key
  if (!kIsWeb) {
    Stripe.publishableKey = 'pk_test_51UN2PdKGnYmWIfAiN3XLjEJ9hmOmCJytN65y6LARBGNu9t5SPj20mPWh03CglgPmEdfkFkoCVdA6TABhTyKxFu9g00BVuIwbs8';
    await Stripe.instance.applySettings();
  }

  runApp(const SportSpaceApp());
}

class SportSpaceApp extends StatelessWidget {
  const SportSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AccountSettingsService.darkModeEnabled,
      builder: (context, darkMode, _) => MaterialApp(
        title: 'SportSpace',
        debugShowCheckedModeBanner: false,
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryTeal,
            primary: AppColors.primaryTeal,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryTeal,
            brightness: Brightness.dark,
          ),
        ),
        home: const LaunchScreen(),
      ),
    );
  }
}
