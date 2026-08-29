import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/home_screen.dart';
import '../../domain/models/user_session.dart';

class AdminRoleOption {
  final String title;
  final String description;
  final IconData icon;
  final Color circleColor;
  final Color iconColor;

  const AdminRoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.circleColor,
    required this.iconColor,
  });
}

/// Screen 4B: Setup Your Administrator Role
class AdminRoleSelectionScreen extends StatefulWidget {
  const AdminRoleSelectionScreen({super.key});

  @override
  State<AdminRoleSelectionScreen> createState() => _AdminRoleSelectionScreenState();
}

class _AdminRoleSelectionScreenState extends State<AdminRoleSelectionScreen> {
  String? _selectedRole;

  static const List<AdminRoleOption> _adminRoles = [
    AdminRoleOption(
      title: 'Police',
      description: 'Police and security coordination',
      icon: Icons.local_police_rounded,
      circleColor: Color(0xFFE8EAF6),
      iconColor: Color(0xFF1A237E),
    ),
    AdminRoleOption(
      title: 'NGO Head',
      description: 'NGO and volunteer coordination',
      icon: Icons.corporate_fare_rounded,
      circleColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
    ),
    AdminRoleOption(
      title: 'Dindi Pramukh',
      description: 'Dindi-level coordination',
      icon: Icons.flag_rounded,
      circleColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
    ),
    AdminRoleOption(
      title: 'Management Head',
      description: 'Overall Wari operations and management',
      icon: Icons.hub_rounded,
      circleColor: Color(0xFFE0F2F1),
      iconColor: Color(0xFF00695C),
    ),
  ];

  void _onSelectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _onContinue() {
    if (_selectedRole == null) return;

    // Save in temporary in-memory state
    UserSession.instance.userState.administratorRole = _selectedRole;

    // Navigate to existing Home / Volunteer Dashboard
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/home'),
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedRole != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_transparent.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.wifi_off_rounded, color: AppColors.outline, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title & Subtitle
              Text(
                'Setup Your Administrator Role',
                style: AppTypography.headlineLg.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your administrative responsibility.',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 4 Selectable Administrator Options
              ..._adminRoles.map((role) {
                final isSelected = _selectedRole == role.title;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onSelectRole(role.title),
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Circular icon container
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: role.circleColor,
                              ),
                              child: Icon(
                                role.icon,
                                color: role.iconColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Title & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.title,
                                    style: AppTypography.headlineMd.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role.description,
                                    style: AppTypography.bodyMd.copyWith(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Selection radio indicator
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected ? AppColors.primary : AppColors.border,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Bottom Continue Action
              SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: canContinue ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withAlpha(110),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withAlpha(180),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
