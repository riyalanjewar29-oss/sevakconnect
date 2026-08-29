import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

void showLogoutDialog(
  BuildContext context, {
  VoidCallback? onLogout,
}) {
  showDialog(
    context: context,
    builder: (ctx) => LogoutDialog(onConfirmLogout: onLogout),
  );
}

class LogoutDialog extends StatelessWidget {
  final VoidCallback? onConfirmLogout;

  const LogoutDialog({
    super.key,
    this.onConfirmLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Confirm Logout',
                    style: AppTypography.headlineMd(color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to end your operational command session? You will need to authenticate again to access the dashboard.',
              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 44),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onConfirmLogout != null) {
                      onConfirmLogout!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.secondary,
                          content: Text('Logged out of command session.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    minimumSize: const Size(100, 44),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
