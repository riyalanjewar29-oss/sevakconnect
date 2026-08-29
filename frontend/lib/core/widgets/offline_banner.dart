import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Offline-First Banner Component (DESIGN.md)
/// Deep Navy strip when Online, shifts to Moderate Yellow/Amber when Working Offline.
/// Persistent slot below the header.
class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onToggleState;

  const OfflineBanner({
    super.key,
    required this.isOnline,
    this.onToggleState,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOnline ? AppColors.bannerOnline : AppColors.bannerOffline;
    final icon = isOnline ? Icons.wifi : Icons.wifi_off_rounded;
    final text = isOnline
        ? 'Online • Connected to Sevak Network'
        : 'Working Offline • Local Sync Active';

    return InkWell(
      onTap: onToggleState,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                text,
                style: AppTypography.labelSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51), // 20% opacity
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                isOnline ? 'LIVE' : 'QUEUE (3)',
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
