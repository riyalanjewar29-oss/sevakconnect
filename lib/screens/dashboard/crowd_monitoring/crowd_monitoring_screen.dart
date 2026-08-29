import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/crowd_condition.dart';
import '../../../services/admin_dashboard_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/section_header.dart';

class CrowdMonitoringScreen extends StatefulWidget {
  const CrowdMonitoringScreen({super.key});

  @override
  State<CrowdMonitoringScreen> createState() => _CrowdMonitoringScreenState();
}

class _CrowdMonitoringScreenState extends State<CrowdMonitoringScreen> {
  final TextEditingController _searchController = TextEditingController();
  CrowdLevel? _levelFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = context.watch<AdminDashboardService>();
    final filteredConditions = dashboardService.filterCrowdConditions(
      query: _searchController.text,
      crowdLevel: _levelFilter,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const SectionHeader(
            title: 'Crowd Density & Sector Monitoring',
            subtitle:
                'Real-time headcount estimates, queue flow velocities, density tiers, and bottleneck detection across all pilgrimage zones.',
            icon: Icons.people_outline_rounded,
          ),

          const SizedBox(height: 20),

          // Filter Toolbar
          _buildFilterToolbar(context),

          const SizedBox(height: 16),

          // Crowd Condition Table Container
          Container(
            width: double.infinity,
            decoration: AppTheme.cardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                  ),
                  child: Row(
                    children: [
                      _buildHeaderCell('Zone / Sector', flex: 3),
                      _buildHeaderCell('Crowd Level', flex: 2),
                      _buildHeaderCell('Location Details', flex: 4),
                      _buildHeaderCell('Last Update', flex: 2),
                      _buildHeaderCell('Reported By', flex: 2),
                      _buildHeaderCell('Actions', flex: 2),
                    ],
                  ),
                ),

                // Table Rows or Clean Empty State
                if (filteredConditions.isEmpty)
                  const EmptyState(
                    title: 'No crowd condition reports found',
                    message:
                        'Live sector headcount reports, river ghat density measurements, and darshan line flows will populate here as field marshals submit telemetry.',
                    icon: Icons.cell_tower_rounded,
                    verticalPadding: 64,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredConditions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final item = filteredConditions[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        color: idx.isEven ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(item.zoneId, style: AppTypography.labelLg(color: AppColors.onSurface)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge.fromCrowdLevel(item.crowdLevel, timestamp: item.createdAt),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(item.description, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(DateFormat('HH:mm').format(item.createdAt), style: AppTypography.labelSm()),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(item.reportedBy, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.secondary,
                                      content: Text('Inspecting telemetry for ${item.zoneId}'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.analytics_outlined, size: 16),
                                label: const Text('Inspect'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;
          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: _buildLevelFilter(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildLevelFilter(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'SEARCH ZONES / SECTORS',
        hintText: 'Search by zone name or location...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
              )
            : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLevelFilter() {
    return DropdownButtonFormField<CrowdLevel?>(
      initialValue: _levelFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'CROWD LEVEL'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Crowd Levels')),
        ...CrowdLevel.values.map(
          (lvl) => DropdownMenuItem(
            value: lvl,
            child: Text(
              lvl.displayName,
              style: AppTypography.labelSm(color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (val) => setState(() => _levelFilter = val),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSm(
          color: AppColors.onSecondary,
        ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
