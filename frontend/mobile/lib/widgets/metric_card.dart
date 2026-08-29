import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final Widget? trailingBadge;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBackgroundColor = AppColors.primaryContainer,
    this.valueColor,
    this.onTap,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.display(
                    color: valueColor ?? iconColor,
                  ).copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.labelSm(color: const Color(0xFF888888)).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
