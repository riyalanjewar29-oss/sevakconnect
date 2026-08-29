import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';

class ChandrabhagaScreen extends StatelessWidget {
  const ChandrabhagaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const SectionHeader(
            title: 'Chandrabhaga River Bed & Ghats Safety',
            subtitle:
                'Monitor riverbank devotee density, water flow speeds, and enforce restricted entry gates during surges.',
            icon: Icons.water_drop_rounded,
          ),

          const SizedBox(height: 20),

          // River Zones Grid Container
          Container(
            width: double.infinity,
            decoration: AppTheme.cardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RIVER GHATS & BATHING ZONES',
                        style: AppTypography.labelSm(
                          color: AppColors.onSecondary,
                        ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withAlpha(50),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '0 GHATS ACTIVE',
                          style: AppTypography.labelSm(
                            color: AppColors.onSecondary,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pure Empty State
                const EmptyState(
                  title: 'No Chandrabhaga zone data available',
                  message:
                      'River ghat telemetry, current flow speeds, bathing capacities, and restricted entry controls will appear here once ghat sensors and marshals connect.',
                  icon: Icons.water_drop_outlined,
                  verticalPadding: 64,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
