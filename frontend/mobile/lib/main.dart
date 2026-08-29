import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/admin_dashboard_service.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AdminDashboardService(),
      child: const SevakConnectApp(),
    ),
  );
}

class SevakConnectApp extends StatelessWidget {
  const SevakConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
