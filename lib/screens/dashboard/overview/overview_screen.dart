import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/admin_dashboard_service.dart';
import '../../../models/crowd_condition.dart';
import '../../../models/volunteer.dart';
import '../../../widgets/metric_card.dart';
import '../../../widgets/donut_summary_chart.dart';

class OverviewScreen extends StatelessWidget {
  final VoidCallback? onNavigateToMap;
  final VoidCallback? onNavigateToEmergencies;
  final VoidCallback? onNavigateToCrowd;
  final VoidCallback? onNavigateToVolunteers;

  const OverviewScreen({
    super.key,
    this.onNavigateToMap,
    this.onNavigateToEmergencies,
    this.onNavigateToCrowd,
    this.onNavigateToVolunteers,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final dashboardService = context.watch<AdminDashboardService>();
    final metrics = dashboardService.metrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Row: 4 Metric Cards
          _buildMetricsRow(context, isDesktop, metrics),

          const SizedBox(height: 20),

          // 2. Middle Row: Live Situation (Map) & Recent Emergencies
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 58,
                  child: _buildLiveSituationCard(context, dashboardService),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 42,
                  child: _buildRecentEmergenciesCard(context, dashboardService),
                ),
              ],
            )
          else ...[
            _buildLiveSituationCard(context, dashboardService),
            const SizedBox(height: 20),
            _buildRecentEmergenciesCard(context, dashboardService),
          ],

          const SizedBox(height: 20),

          // 3. Bottom Row: Critical Alerts, Crowd Status Summary, Volunteer Status Summary
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCriticalAlertsCard(context, dashboardService),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCrowdStatusCard(context, dashboardService),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildVolunteerStatusCard(context, dashboardService),
                ),
              ],
            )
          else ...[
            _buildCriticalAlertsCard(context, dashboardService),
            const SizedBox(height: 20),
            _buildCrowdStatusCard(context, dashboardService),
            const SizedBox(height: 20),
            _buildVolunteerStatusCard(context, dashboardService),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsRow(
    BuildContext context,
    bool isDesktop,
    dynamic metrics,
  ) {
    final crossAxisCount = isDesktop
        ? 4
        : MediaQuery.of(context).size.width >= 600
            ? 2
            : 1;

    final cards = [
      MetricCard(
        title: 'Active Emergencies',
        value: '${metrics.activeEmergencies}',
        subtitle: metrics.activeEmergencies > 0
            ? '${metrics.activeEmergencies} active emergencies'
            : 'No active emergencies',
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFFFF7A00),
        iconBackgroundColor: const Color(0xFFFFF3E8),
        valueColor: const Color(0xFFFF7A00),
        onTap: onNavigateToEmergencies,
      ),
      MetricCard(
        title: 'Critical Zones',
        value: '${metrics.criticalZones}',
        subtitle: metrics.criticalZones > 0
            ? '${metrics.criticalZones} critical zones'
            : 'No critical zones',
        icon: Icons.groups_rounded,
        iconColor: const Color(0xFFE53935),
        iconBackgroundColor: const Color(0xFFFFEBEE),
        valueColor: const Color(0xFFE53935),
        onTap: onNavigateToMap,
      ),
      MetricCard(
        title: 'Active Volunteers',
        value: '${metrics.activeVolunteers}',
        subtitle: metrics.activeVolunteers > 0
            ? '${metrics.activeVolunteers} volunteers active'
            : 'No volunteers active',
        icon: Icons.person_rounded,
        iconColor: const Color(0xFF2E7D32),
        iconBackgroundColor: const Color(0xFFE8F5E9),
        valueColor: const Color(0xFF2E7D32),
        onTap: onNavigateToVolunteers,
      ),
      MetricCard(
        title: 'Unresolved Incidents',
        value: '${metrics.unresolvedIncidents}',
        subtitle: metrics.unresolvedIncidents > 0
            ? '${metrics.unresolvedIncidents} unresolved incidents'
            : 'No unresolved incidents',
        icon: Icons.assignment_outlined,
        iconColor: const Color(0xFF7C4DFF),
        iconBackgroundColor: const Color(0xFFEDE7F6),
        valueColor: const Color(0xFF7C4DFF),
        onTap: onNavigateToEmergencies,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      itemCount: cards.length,
      itemBuilder: (context, idx) => cards[idx],
    );
  }

  Widget _buildLiveSituationCard(BuildContext context, AdminDashboardService service) {
    return Container(
      height: 330,
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'LIVE SITUATION',
              style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Map Area with Center Overlay
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Stack(
                children: [
                  // OpenStreetMap Background
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: AppConstants.pandharpurCenter,
                      initialZoom: 15.0,
                      minZoom: 13.0,
                      maxZoom: 18.0,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConstants.osmTileUrl,
                        userAgentPackageName: AppConstants.osmUserAgent,
                        errorTileCallback: (tile, error, stackTrace) {},
                      ),
                    ],
                  ),

                  // Center Message Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(240),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              size: 18,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No live incidents or\ncrowd reports',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelLg(color: const Color(0xFF333333)).copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Right Zoom Controls
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.add, size: 18, color: Color(0xFF555555)),
                            ),
                          ),
                          Container(height: 1, width: 24, color: const Color(0xFFE0E0E0)),
                          InkWell(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove, size: 18, color: Color(0xFF555555)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEmergenciesCard(BuildContext context, AdminDashboardService service) {
    return Container(
      height: 330,
      padding: const EdgeInsets.all(20),
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
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT EMERGENCIES',
                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: onNavigateToEmergencies,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: AppTypography.labelSm(color: const Color(0xFFFF6600)).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Center Empty State
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    size: 44,
                    color: Color(0xFFFFAB91),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No active emergencies',
                    style: AppTypography.headlineMd(color: const Color(0xFF333333)).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All clear for now',
                    style: AppTypography.labelSm(color: const Color(0xFF888888)).copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertsCard(BuildContext context, AdminDashboardService service) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
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
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CRITICAL ALERTS',
                style: AppTypography.labelLg(color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: onNavigateToEmergencies,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'View All',
                    style: AppTypography.labelSm(color: const Color(0xFFFF6600)).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Center Empty State
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 38,
                    color: Color(0xFFFFCC80),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No critical alerts',
                    style: AppTypography.headlineMd(color: const Color(0xFF333333)).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No alerts at the moment',
                    style: AppTypography.labelSm(color: const Color(0xFF888888)).copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdStatusCard(BuildContext context, AdminDashboardService service) {
    return DonutSummaryCard(
      title: 'CROWD STATUS SUMMARY',
      onViewAll: onNavigateToCrowd,
      emptyText: 'No data\navailable',
      items: [
        LegendItemData(
          label: 'Normal',
          count: service.crowdConditions.where((c) => c.crowdLevel == CrowdLevel.normal).length,
          color: const Color(0xFF2E7D32),
        ),
        LegendItemData(
          label: 'Moderate',
          count: service.crowdConditions.where((c) => c.crowdLevel == CrowdLevel.moderate).length,
          color: const Color(0xFFFFA000),
        ),
        LegendItemData(
          label: 'High',
          count: service.crowdConditions.where((c) => c.crowdLevel == CrowdLevel.high).length,
          color: const Color(0xFFFF7A00),
        ),
        LegendItemData(
          label: 'Critical',
          count: service.crowdConditions.where((c) => c.crowdLevel == CrowdLevel.critical).length,
          color: const Color(0xFFE53935),
        ),
      ],
    );
  }

  Widget _buildVolunteerStatusCard(BuildContext context, AdminDashboardService service) {
    return DonutSummaryCard(
      title: 'VOLUNTEER STATUS SUMMARY',
      onViewAll: onNavigateToVolunteers,
      emptyText: 'No data\navailable',
      items: [
        LegendItemData(
          label: 'Active',
          count: service.volunteers.where((v) => v.status == VolunteerStatus.active).length,
          color: const Color(0xFF2E7D32),
        ),
        LegendItemData(
          label: 'Available',
          count: service.volunteers.where((v) => v.status == VolunteerStatus.available).length,
          color: const Color(0xFF1E88E5),
        ),
        LegendItemData(
          label: 'Busy',
          count: service.volunteers.where((v) => v.status == VolunteerStatus.busy).length,
          color: const Color(0xFFFF7A00),
        ),
        LegendItemData(
          label: 'Offline',
          count: service.volunteers.where((v) => v.status == VolunteerStatus.offline).length,
          color: const Color(0xFF9E9E9E),
        ),
      ],
    );
  }
}
