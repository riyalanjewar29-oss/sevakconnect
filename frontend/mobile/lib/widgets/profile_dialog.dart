import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

void showProfileDialog(
  BuildContext context, {
  String role = 'Admin',
  VoidCallback? onRoleToggle,
}) {
  showDialog(
    context: context,
    builder: (ctx) => ProfileDialog(role: role, onRoleToggle: onRoleToggle),
  );
}

class ProfileDialog extends StatelessWidget {
  final String role;
  final VoidCallback? onRoleToggle;

  const ProfileDialog({
    super.key,
    required this.role,
    this.onRoleToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPolice = role.toLowerCase().contains('police');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isPolice ? AppColors.secondary : AppColors.primary,
                      foregroundColor: Colors.white,
                      child: Icon(
                        isPolice ? Icons.local_police_rounded : Icons.admin_panel_settings_rounded,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPolice ? 'Officer On Duty' : 'Command Administrator',
                          style: AppTypography.headlineMd(color: AppColors.onSurface),
                        ),
                        Text(
                          role.toUpperCase(),
                          style: AppTypography.labelSm(
                            color: isPolice ? AppColors.secondary : AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Profile Attributes
            _buildProfileRow('Station / Command', 'Pandharpur Central Control Room'),
            const SizedBox(height: 12),
            _buildProfileRow('Sector Assigned', 'Core Temple Perimeter & Chandrabhaga Ghat'),
            const SizedBox(height: 12),
            _buildProfileRow('Access Tier', isPolice ? 'Law Enforcement & Rapid Dispatch' : 'Executive Command & System Coordination'),
            const SizedBox(height: 12),
            _buildProfileRow('Session Status', 'Active • Secure Channel'),

            const SizedBox(height: 24),

            // Role Switch Action Button
            if (onRoleToggle != null) ...[
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRoleToggle!();
                },
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: Text('Switch to ${isPolice ? 'Admin' : 'Police'} View'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)
              .copyWith(fontWeight: FontWeight.w700, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
