import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'utils/app_colors.dart';
import 'views/launch_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready for async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configure system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 3. Initialize Stripe with your Publishable Key
  Stripe.publishableKey = 'pk_test_51UN2PdKGnYmWIfAiN3XLjEJ9hmOmCJytN65y6LARBGNu9t5SPj20mPWh03CglgPmEdfkFkoCVdA6TABhTyKxFu9g00BVuIwbs8';
  await Stripe.instance.applySettings();

  runApp(const SportSpaceApp());
}

class SportSpaceApp extends StatelessWidget {
  const SportSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          primary: AppColors.primaryTeal,
        ),
      ),
      home: const LaunchScreen(),
    );
  }
}
