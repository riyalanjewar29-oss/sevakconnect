import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/presentation/screens/login_screen.dart';

/// SevakConnect Splash Screen
/// Displays ONLY the full-screen splash photo (assets/images/splash_bg.jpg)
/// for 2.8 seconds, then navigates seamlessly to the Login Screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Edge-to-edge full screen display so artwork fills the entire display
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Keep full splash photo visible for ~2.8 seconds, then navigate to Login
    _navigationTimer = Timer(const Duration(milliseconds: 2800), _navigateToLogin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/splash_bg.jpg'), context);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    _navigationTimer?.cancel();

    // Restore standard system UI for subsequent screens
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE4),
      body: GestureDetector(
        onTap: _navigateToLogin, // Tap anywhere to proceed immediately
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
