import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/emergency_report.dart';
import '../../../models/volunteer.dart';
import '../../../core/extensions/crowd_level_extension.dart';
import '../../../services/admin_dashboard_service.dart';
import '../../../widgets/empty_state.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();

  // Layer Visibility Toggles
  bool _showEmergencies = true;
  bool _showCrowdReports = true;
  bool _showCriticalZones = true;
  bool _showVolunteers = true;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final dashboardService = context.watch<AdminDashboardService>();

    // Build real markers (strictly 0 fake markers)
    final markers = <Marker>[];

    if (_showEmergencies) {
      for (final e in dashboardService.emergencies) {
        if (e.position != null) {
          markers.add(
            Marker(
              point: e.position!,
              width: 36,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  color: e.severity.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.emergency, color: Colors.white, size: 20),
              ),
            ),
          );
        }
      }
    }

    if (_showCrowdReports) {
      for (final c in dashboardService.crowdConditions) {
        if (c.position != null) {
          markers.add(
            Marker(
              point: c.position!,
              width: 32,
              height: 32,
              child: Container(
                decoration: BoxDecoration(
                  color: c.crowdLevel.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 16),
              ),
            ),
          );
        }
      }
    }

    if (_showVolunteers) {
      for (final v in dashboardService.volunteers) {
        if (v.position != null) {
          markers.add(
            Marker(
              point: v.position!,
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: v.status.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 14),
              ),
            ),
          );
        }
      }
    }

    return Column(
      children: [
        // Layer Filters Toolbar
        _buildLayerFilterToolbar(context),

        const SizedBox(height: 16),

        // Main Map Canvas & Telemetry Panel
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Map Area
              Expanded(
                flex: 7,
                child: Container(
                  decoration: AppTheme.cardDecoration(),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // OpenStreetMap Base
                      FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: AppConstants.pandharpurCenter,
                          initialZoom: 15.2,
                          minZoom: AppConstants.minZoom,
                          maxZoom: AppConstants.maxZoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: AppConstants.osmTileUrl,
                            userAgentPackageName: AppConstants.osmUserAgent,
                            errorTileCallback: (tile, error, stackTrace) {},
                          ),
                          if (markers.isNotEmpty)
                            MarkerLayer(markers: markers),
                        ],
                      ),

                      // Clean Telemetry Status Overlay
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withAlpha(240),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadowAmbient,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                markers.isEmpty ? Icons.info_outline_rounded : Icons.radar_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                markers.isEmpty
                                    ? 'Map Telemetry Ready • No active markers'
                                    : '${markers.length} Active GPS markers streaming',
                                style: AppTypography.labelSm(color: AppColors.onSurface)
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Map Controls (Zoom / Recenter)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'live_map_zoom_in',
                              backgroundColor: AppColors.surfaceContainerLowest,
                              foregroundColor: AppColors.secondary,
                              onPressed: () {
                                final currentZoom = _mapController.camera.zoom;
                                _mapController.move(
                                  _mapController.camera.center,
                                  currentZoom + 1,
                                );
                              },
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'live_map_zoom_out',
                              backgroundColor: AppColors.surfaceContainerLowest,
                              foregroundColor: AppColors.secondary,
                              onPressed: () {
                                final currentZoom = _mapController.camera.zoom;
                                _mapController.move(
                                  _mapController.camera.center,
                                  currentZoom - 1,
                                );
                              },
                              child: const Icon(Icons.remove),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: 'live_map_recenter',
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.onSecondary,
                              tooltip: 'Recenter to Pandharpur',
                              onPressed: () {
                                _mapController.move(
                                  AppConstants.pandharpurCenter,
                                  15.2,
                                );
                              },
                              child: const Icon(Icons.my_location_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Telemetry Side Inspector (Desktop Only)
              if (isDesktop) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 360,
                  child: _buildInspectorPanel(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayerFilterToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.layers_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ACTIVE MAP LAYERS:',
                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Emergency Locations'),
                selected: _showEmergencies,
                onSelected: (val) => setState(() => _showEmergencies = val),
                avatar: const Icon(Icons.emergency_rounded, size: 14, color: AppColors.statusCritical),
                visualDensity: VisualDensity.compact,
              ),
              FilterChip(
                label: const Text('Crowd Reports'),
                selected: _showCrowdReports,
                onSelected: (val) => setState(() => _showCrowdReports = val),
                avatar: const Icon(Icons.people_rounded, size: 14, color: AppColors.statusModerate),
                visualDensity: VisualDensity.compact,
              ),
              FilterChip(
                label: const Text('Critical Zones'),
                selected: _showCriticalZones,
                onSelected: (val) => setState(() => _showCriticalZones = val),
                avatar: const Icon(Icons.cell_tower_rounded, size: 14, color: AppColors.statusHigh),
                visualDensity: VisualDensity.compact,
              ),
              FilterChip(
                label: const Text('Volunteer Locations'),
                selected: _showVolunteers,
                onSelected: (val) => setState(() => _showVolunteers = val),
                avatar: const Icon(Icons.badge_outlined, size: 14, color: AppColors.secondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorPanel() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.onSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Map Telemetry Inspector',
                    style: AppTypography.labelLg(color: AppColors.onSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: EmptyState(
              title: 'No marker selected',
              message:
                  'Clicking on live map telemetry markers for emergencies, crowd sectors, or deployed volunteers will display instant coordinates and operational status.',
              icon: Icons.place_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
