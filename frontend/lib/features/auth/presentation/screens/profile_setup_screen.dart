import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/user_session.dart';
import 'role_selection_screen.dart';

/// In-memory profile data model for SevakConnect
class UserProfile {
  final String fullName;
  final String mobileNumber;
  final DateTime savedAt;

  const UserProfile({
    required this.fullName,
    required this.mobileNumber,
    required this.savedAt,
  });
}

/// SevakConnect Profile Setup Screen
/// Collects ONLY two pieces of information:
/// 1. Full Name
/// 2. Mobile Number (Read-only, verified from Login/OTP)
class ProfileSetupScreen extends StatefulWidget {
  final String mobileNumber;

  const ProfileSetupScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  String? _nameError;
  bool _isSaved = false;
  UserProfile? _savedProfile;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  /// Formats the verified mobile number cleanly as +91 XXXXX XXXXX
  String get _formattedMobileNumber {
    final clean = widget.mobileNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      final part1 = clean.substring(0, 5);
      final part2 = clean.substring(5, 10);
      return '+91 $part1 $part2';
    } else if (clean.length > 10) {
      final last10 = clean.substring(clean.length - 10);
      final part1 = last10.substring(0, 5);
      final part2 = last10.substring(5, 10);
      return '+91 $part1 $part2';
    } else if (clean.isNotEmpty) {
      return '+91 $clean';
    }
    return '+91 98765 43210';
  }

  void _onNameChanged(String val) {
    if (_nameError != null) {
      setState(() {
        _nameError = null;
      });
    }
    if (_isSaved) {
      setState(() {
        _isSaved = false;
      });
    }
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    final trimmedName = _nameController.text.trim();

    // 1. Validate Full Name
    if (trimmedName.isEmpty) {
      setState(() {
        _nameError = 'Please enter your full name.';
        _isSaved = false;
      });
      _nameFocusNode.requestFocus();
      return;
    }

    // 2. Make sure mobile number exists
    if (widget.mobileNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number not found. Please log in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 3. Save profile information locally / in memory
    final profile = UserProfile(
      fullName: trimmedName,
      mobileNumber: _formattedMobileNumber,
      savedAt: DateTime.now(),
    );

    // Save to global user session
    UserSession.instance.userState.fullName = trimmedName;
    UserSession.instance.userState.mobileNumber = _formattedMobileNumber;

    setState(() {
      _nameError = null;
      _savedProfile = profile;
      _isSaved = true;
    });

    // 4. Show success confirmation
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Profile saved successfully.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.statusNormal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );

    // 5. Navigate to Role Selection Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/role-selection'),
        builder: (context) => const RoleSelectionScreen(),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Section: Centered Official Logo & Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          // Standalone Transparent Official SevakConnect Logo
                          const BrandLogo(width: 190),

                          const SizedBox(height: 24),

                          // Heading
                          Text(
                            'CREATE YOUR PROFILE',
                            style: AppTypography.headlineLg.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Tell us a little about yourself.',
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Form Fields Section: ONLY Full Name & Mobile Number
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. FULL NAME INPUT FIELD
                          CustomTextField(
                            label: 'FULL NAME *',
                            hint: 'Enter your full name',
                            controller: _nameController,
                            errorText: _nameError,
                            keyboardType: TextInputType.name,
                            onChanged: _onNameChanged,
                          ),

                          const SizedBox(height: 20),

                          // 2. READ-ONLY MOBILE NUMBER FIELD
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Visible label
                              Text(
                                'MOBILE NUMBER',
                                style: AppTypography.labelLg.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8.0),

                              // Read-only container with 56px height
                              Container(
                                width: double.infinity,
                                height: 56.0,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant.withAlpha(120),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formattedMobileNumber,
                                      style: AppTypography.bodyLg.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.statusNormal,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.textMuted,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 6.0),

                              // Verified helper indicator
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: AppColors.statusNormal,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Verified mobile number',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.statusNormal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Success confirmation card (shown after saving)
                          if (_isSaved && _savedProfile != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColors.statusNormalBg,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: AppColors.statusNormal,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.statusNormal,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Profile saved successfully.',
                                          style: AppTypography.labelLg.copyWith(
                                            color: AppColors.statusNormal,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_savedProfile!.fullName} • ${_savedProfile!.mobileNumber}',
                                          style: AppTypography.bodyLg.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Bottom Continue Action
                      Column(
                        children: [
                          PrimaryButton(
                            text: _isSaved ? 'SAVED' : 'CONTINUE',
                            onPressed: _saveProfile,
                          ),
                          const SizedBox(height: 8),
                        ],
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
