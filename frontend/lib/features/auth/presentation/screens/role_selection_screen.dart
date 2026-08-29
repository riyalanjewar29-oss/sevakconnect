import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/home_screen.dart';
import '../../domain/models/user_session.dart';
import 'admin_role_selection_screen.dart';

/// Screen 4: Setup Your Role
/// Strictly matches the uploaded reference design media_1787996718869.png
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole; // 'Volunteer' | 'Administrator'
  String? _selectedAffiliation;

  final List<String> _affiliationOptions = [
    'Choose your organization...',
    'Select Dindi/NGO',
    'Dindi',
    'NGO',
    'Independent Seva',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAffiliation = _affiliationOptions[0];
  }

  void _onSelectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _onContinue() {
    if (_selectedRole == null) return;

    // Save in temporary in-memory state
    UserSession.instance.userState.mainRole = _selectedRole;
    UserSession.instance.userState.affiliation =
        _selectedAffiliation == _affiliationOptions[0] ? null : _selectedAffiliation;

    if (_selectedRole == 'Volunteer') {
      // Direct navigation to existing Home / Volunteer Dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/home'),
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } else if (_selectedRole == 'Administrator') {
      // Navigate to Administrator Role Selection
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/admin-role-selection'),
          builder: (context) => const AdminRoleSelectionScreen(),
        ),
      );
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title & Subtitle
              Text(
                'Setup Your Role',
                style: AppTypography.headlineLg.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you will serve in the upcoming\nevent.',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // CARD 1: Volunteer
              _buildRoleCard(
                roleId: 'Volunteer',
                title: 'Volunteer',
                description: 'General service and support',
                circleColor: const Color(0xFFF99827),
                icon: Icons.volunteer_activism_rounded,
                iconColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // CARD 2: Administrator
              _buildRoleCard(
                roleId: 'Administrator',
                title: 'Administrator',
                description: 'Managing Wari operations',
                circleColor: const Color(0xFF90A0FE),
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFF283593),
              ),

              const SizedBox(height: 20),

              // AFFILIATION SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Affiliation',
                      style: AppTypography.headlineMd.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.border.withAlpha(120), height: 1, thickness: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Select Dindi/NGO',
                      style: AppTypography.labelLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 52.0,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.border, width: 1.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAffiliation,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          style: AppTypography.bodyLg.copyWith(
                            color: _selectedAffiliation == _affiliationOptions[0]
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontSize: 15,
                          ),
                          items: _affiliationOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(
                                opt,
                                style: TextStyle(
                                  color: opt == _affiliationOptions[0]
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedAffiliation = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BOTTOM CONTINUE ACTION
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

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String description,
    required Color circleColor,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedRole == roleId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSelectRole(roleId),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
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
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large circular icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: AppTypography.headlineMd.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // Description
              Text(
                description,
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
