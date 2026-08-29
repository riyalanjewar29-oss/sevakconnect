import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import 'profile_setup_screen.dart';

/// SevakConnect OTP Verification Screen
/// Built strictly per specification with 6-digit OTP input, resend timer,
/// phone number masking, demo OTP support, and accessibility.
class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  final List<FocusNode> _keyboardFocusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  Timer? _timer;
  int _resendCountdown = 30;
  bool _canResend = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    for (var focusNode in _keyboardFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _resendCountdown = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _enteredOtp {
    return _controllers.map((c) => c.text).join();
  }

  String get _maskedPhoneNumber {
    final clean = widget.mobileNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 10) {
      final last4 = clean.substring(clean.length - 4);
      return '+91 ******$last4';
    } else if (clean.isNotEmpty) {
      return '+91 $clean';
    }
    return '+91 ******1024';
  }

  void _onDigitChanged(int index, String value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    if (value.length > 1) {
      // Handle paste or multi-digit input
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        }
      }
      if (digits.length >= _otpLength) {
        _focusNodes[_otpLength - 1].requestFocus();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _fillDemoOtp() {
    const demo = '123456';
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].text = demo[i];
    }
    setState(() {
      _errorMessage = null;
    });
    _focusNodes[_otpLength - 1].requestFocus();
  }

  void _resendOtpMock() {
    if (!_canResend) return;

    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mock OTP resent to your mobile number.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _verifyOtp() {
    final otp = _enteredOtp;

    if (otp.length < _otpLength) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit OTP.';
      });
      return;
    }

    // Demo Verification Check (123456)
    if (otp == '123456') {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });

      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _navigateToProfileSetup();
      });
    } else {
      // Incorrect OTP handling
      setState(() {
        _errorMessage = 'Incorrect OTP. Please try again.';
      });

      // Clear all fields and focus back to digit 1
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _navigateToProfileSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/profile-setup'),
        builder: (context) => ProfileSetupScreen(
          mobileNumber: widget.mobileNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Branding & Heading Section
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          // Standalone Transparent Official Logo
                          const BrandLogo(width: 200),

                          const SizedBox(height: 24),

                          // Heading
                          Text(
                            'VERIFY YOUR MOBILE NUMBER',
                            style: AppTypography.headlineLg.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Instruction
                          Text(
                            'Enter the 6-digit OTP sent to your mobile number.',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          // Phone Number Mask
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'OTP sent to ',
                                style: AppTypography.bodyLg.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _maskedPhoneNumber,
                                style: AppTypography.bodyLg.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // OTP Boxes & Form Actions Section
                      Column(
                        children: [
                          // 6 Individual OTP Boxes Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_otpLength, (index) {
                              final hasError = _errorMessage != null;

                              return Semantics(
                                label: 'OTP digit ${index + 1}',
                                child: SizedBox(
                                  width: 46,
                                  height: 56,
                                  child: KeyboardListener(
                                    focusNode: _keyboardFocusNodes[index],
                                    onKeyEvent: (event) => _onKeyEvent(index, event),
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      style: AppTypography.headlineLg.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        counterText: '',
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: AppColors.surface,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: hasError
                                                ? AppColors.error
                                                : AppColors.border,
                                            width: 1.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            color: hasError
                                                ? AppColors.error
                                                : AppColors.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) => _onDigitChanged(index, val),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          // Error Message Display
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _errorMessage!,
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Resend OTP Countdown / Trigger Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ",
                                style: AppTypography.bodyLg.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: _canResend ? _resendOtpMock : null,
                                child: Text(
                                  _canResend
                                      ? 'RESEND OTP'
                                      : 'Resend OTP in ${_resendCountdown}s',
                                  style: AppTypography.labelLg.copyWith(
                                    color: _canResend
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Primary Action: VERIFY OTP
                          PrimaryButton(
                            text: 'VERIFY OTP',
                            isLoading: _isLoading,
                            loadingText: 'VERIFYING...',
                            onPressed: _verifyOtp,
                          ),

                          const SizedBox(height: 16),

                          // Demo Helper Option: USE DEMO OTP
                          TextButton(
                            onPressed: _fillDemoOtp,
                            child: Text(
                              'USE DEMO OTP (123456)',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
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
