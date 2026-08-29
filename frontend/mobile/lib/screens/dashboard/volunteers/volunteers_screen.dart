import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/volunteer.dart';
import '../../../services/admin_dashboard_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/section_header.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _teamFilter = 'All';
  VolunteerStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardService = context.watch<AdminDashboardService>();
    final filteredVolunteers = dashboardService.filterVolunteers(
      query: _searchController.text,
      team: _teamFilter,
      status: _statusFilter,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const SectionHeader(
            title: 'Volunteer Force Deployment Roster',
            subtitle:
                'Field personnel deployment, duty status, assigned dindis/teams, and real-time operational sector tracking.',
            icon: Icons.badge_outlined,
          ),

          const SizedBox(height: 20),

          // Search & Filter Toolbar
          _buildFilterToolbar(context),

          const SizedBox(height: 16),

          // Volunteers Roster Table Container
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
                      _buildHeaderCell('Volunteer Name', flex: 3),
                      _buildHeaderCell('Role', flex: 2),
                      _buildHeaderCell('Dindi / Team', flex: 2),
                      _buildHeaderCell('Status', flex: 2),
                      _buildHeaderCell('Current Location', flex: 3),
                      _buildHeaderCell('Contact', flex: 2),
                      _buildHeaderCell('Actions', flex: 2),
                    ],
                  ),
                ),

                // Table Rows or Clean Empty State
                if (filteredVolunteers.isEmpty)
                  const EmptyState(
                    title: 'No volunteers registered or on duty',
                    message:
                        'Registered volunteers, on-duty field status, sector assignments, and contact channels will appear here when Sevak personnel check in.',
                    icon: Icons.groups_outlined,
                    verticalPadding: 64,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredVolunteers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final v = filteredVolunteers[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        color: idx.isEven ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryContainer.withAlpha(120),
                                    child: const Icon(Icons.person, size: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(v.name, style: AppTypography.labelLg(color: AppColors.onSurface)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(v.role, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(v.team, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge.fromVolunteerStatus(v.status, timestamp: v.lastActive),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(v.currentLocation, style: AppTypography.bodyMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(v.phone.isNotEmpty ? v.phone : '—', style: AppTypography.labelSm()),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.secondary,
                                      content: Text('Contacting ${v.name}'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.phone_outlined, size: 16),
                                label: const Text('Contact'),
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
                  child: _buildTeamFilter(),
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
                    Expanded(child: _buildTeamFilter()),
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
        labelText: 'SEARCH VOLUNTEERS',
        hintText: 'Search by name, phone, role...',
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

  Widget _buildTeamFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _teamFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'DINDI / TEAM'),
      items: [
        'All',
        'Dindi 108',
        'Dindi 1',
        'Dindi 27',
        'Dindi 42',
        'Dindi 56',
        'Dindi 89',
        'Medical Rapid Response',
        'Crowd Safety Marshals',
        'General Coordination',
      ].map((t) {
        return DropdownMenuItem(
          value: t,
          child: Text(
            t,
            style: AppTypography.labelSm(color: AppColors.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _teamFilter = val);
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<VolunteerStatus?>(
      initialValue: _statusFilter,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'DUTY STATUS'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Statuses')),
        ...VolunteerStatus.values.map(
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
