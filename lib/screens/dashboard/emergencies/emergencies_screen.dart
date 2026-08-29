import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/emergency_report.dart';
import '../../../services/admin_dashboard_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/section_header.dart';

class EmergenciesScreen extends StatefulWidget {
  const EmergenciesScreen({super.key});

  @override
  State<EmergenciesScreen> createState() => _EmergenciesScreenState();
}

class _EmergenciesScreenState extends State<EmergenciesScreen> {
  final TextEditingController _searchController = TextEditingController();
  EmergencySeverity? _severityFilter;
  EmergencyStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEmergencyDetails(BuildContext context, EmergencyReport report, AdminDashboardService service) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: report.severity.containerColor,
                        foregroundColor: report.severity.onContainerColor,
                        child: const Icon(Icons.emergency_rounded, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.type, style: AppTypography.headlineMd(color: AppColors.onSurface)),
                          Text(
                            'REPORT ID: #${report.id.isNotEmpty ? report.id : "NEW"}',
                            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailItem('Severity Level', report.severity.displayName, badge: StatusBadge.fromEmergencySeverity(report.severity)),
              const SizedBox(height: 10),
              _buildDetailItem('Incident Status', report.status.displayName, badge: StatusBadge.fromEmergencyStatus(report.status)),
              const SizedBox(height: 10),
              _buildDetailItem('Location', report.location),
              const SizedBox(height: 10),
              _buildDetailItem('Reported At', DateFormat('yyyy-MM-dd HH:mm').format(report.time)),
              const SizedBox(height: 10),
              _buildDetailItem('Reported By', report.reportedBy),
              if (report.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildDetailItem('Description', report.description),
              ],
              const SizedBox(height: 24),
              // Status Update Actions
              Text(
                'UPDATE STATUS',
                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: report.status == EmergencyStatus.inProgress
                          ? null
                          : () {
                              service.updateEmergencyStatus(report.id, EmergencyStatus.inProgress);
                              Navigator.of(ctx).pop();
                            },
                      child: const Text('Mark In Progress'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: report.status == EmergencyStatus.resolved
                          ? null
                          : () {
                              service.updateEmergencyStatus(report.id, EmergencyStatus.resolved);
                              Navigator.of(ctx).pop();
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusNormal),
                      child: const Text('Resolve'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Widget? badge}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: AppTypography.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: badge ??
              Text(
                value,
                style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14),
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = context.watch<AdminDashboardService>();
    final filteredEmergencies = dashboardService.filterEmergencies(
      query: _searchController.text,
      severity: _severityFilter,
      status: _statusFilter,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const SectionHeader(
            title: 'Emergency Incident Monitoring',
            subtitle:
                'Field emergency transmissions, priority triage levels, sector coordinates, and real-time response coordination.',
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(height: 20),

          // Filter Toolbar
          _buildFilterToolbar(context),

          const SizedBox(height: 16),

          // Emergencies Table Container
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
                      _buildHeaderCell('Emergency Type', flex: 3),
                      _buildHeaderCell('Severity', flex: 2),
                      _buildHeaderCell('Location', flex: 3),
                      _buildHeaderCell('Time', flex: 2),
                      _buildHeaderCell('Reported By', flex: 2),
                      _buildHeaderCell('Status', flex: 2),
                      _buildHeaderCell('Actions', flex: 2),
                    ],
                  ),
                ),

                // Table Rows or Empty State
                if (filteredEmergencies.isEmpty)
                  const EmptyState(
                    title: 'No emergency reports found',
                    message:
                        'Active medical calls, crowd surges, structural alerts, and lost children reports will appear here in real-time.',
                    icon: Icons.check_circle_outline_rounded,
                    verticalPadding: 64,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredEmergencies.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final item = filteredEmergencies[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        color: idx.isEven ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(item.type, style: AppTypography.labelLg(color: AppColors.onSurface)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge.fromEmergencySeverity(item.severity),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(item.location, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(DateFormat('HH:mm').format(item.time), style: AppTypography.labelSm()),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(item.reportedBy, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge.fromEmergencyStatus(item.status),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextButton.icon(
                                onPressed: () => _showEmergencyDetails(context, item, dashboardService),
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: const Text('Manage'),
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
                  flex: 4,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: _buildSeverityFilter(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: _buildStatusFilter(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSeverityFilter()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusFilter()),
                  ],
                ),
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
        labelText: 'SEARCH EMERGENCIES',
        hintText: 'Search by type, location, reporter...',
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

  Widget _buildSeverityFilter() {
    return DropdownButtonFormField<EmergencySeverity?>(
      initialValue: _severityFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'SEVERITY'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Severities')),
        ...EmergencySeverity.values.map(
          (s) => DropdownMenuItem(
            value: s,
            child: Text(
              s.displayName,
              style: AppTypography.labelSm(color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (val) => setState(() => _severityFilter = val),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<EmergencyStatus?>(
      initialValue: _statusFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'STATUS'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Statuses')),
        ...EmergencyStatus.values.map(
          (s) => DropdownMenuItem(
            value: s,
            child: Text(
              s.displayName,
              style: AppTypography.labelSm(color: AppColors.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (val) => setState(() => _statusFilter = val),
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
