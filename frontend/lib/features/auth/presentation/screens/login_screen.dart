import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import 'otp_screen.dart';

/// SevakConnect Login Screen
/// Built to match the exact visual specification in media_1787982600964.png
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _validateAndSendOtp() {
    final text = _phoneController.text.trim();

    setState(() {
      if (text.isEmpty) {
        _errorMessage = 'Please enter your mobile number.';
      } else if (text.length < 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
        _errorMessage = 'Please enter a valid 10-digit mobile number.';
      } else {
        _errorMessage = null;
      }
    });

    if (_errorMessage != null) return;

    // Trigger mock loading & navigation to /otp
    setState(() {
      _isLoading = true;
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _navigateToOtp(text);
    });
  }

  void _continueWithDemo() {
    _navigateToOtp(_phoneController.text.trim().isEmpty ? '9876543210' : _phoneController.text.trim());
  }

  void _navigateToOtp(String number) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/otp'),
        builder: (context) => OtpScreen(mobileNumber: number),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48.0, // Vertically balanced layout
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Section: Centered Logo & Welcome Text
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          // Centered Official Brand Logo
                          const BrandLogo(width: 210),

                          const SizedBox(height: 28),

                          // Welcome Heading (Centered Deep Navy)
                          Text(
                            'WELCOME TO SEVAKCONNECT',
                            style: AppTypography.headlineLg.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Subtitle (Centered Muted Text)
                          Text(
                            'Connecting the people who\nkeep Wari moving.',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.35,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Form Section (Mobile Input & Action Buttons)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mobile Number Input Field
                          CustomTextField(
                            label: 'MOBILE NUMBER',
                            hint: 'Enter mobile number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixText: '+91  ',
                            errorText: _errorMessage,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (val) {
                              if (_errorMessage != null) {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 8),

                          // Lock Icon + Supporting text below input
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "We'll use your number to securely sign you in.",
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Primary Action: SEND OTP (Saffron/Orange Button)
                          PrimaryButton(
                            text: 'SEND OTP',
                            isLoading: _isLoading,
                            loadingText: 'Sending OTP...',
                            onPressed: _validateAndSendOtp,
                          ),

                          const SizedBox(height: 20),

                          // Separator "OR"
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'OR',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Secondary Action: CONTINUE WITH DEMO (Outlined Deep Navy)
                          SecondaryButton(
                            text: 'CONTINUE WITH DEMO',
                            onPressed: _continueWithDemo,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Bottom Statement
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Built for safer, better-coordinated Wari Seva.',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
