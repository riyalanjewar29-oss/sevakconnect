import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class StateViews {
  static Widget loading({String message = 'Loading operational telemetry...'}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  static Widget empty({
    required String title,
    required String message,
    IconData icon = Icons.inbox_outlined,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.headlineMd(color: AppColors.onSurface)
                  .copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  static Widget error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.statusCritical,
            ),
            const SizedBox(height: 12),
            Text(
              'Operational Error Occurred',
              style: AppTypography.headlineMd(color: AppColors.onSurface)
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
