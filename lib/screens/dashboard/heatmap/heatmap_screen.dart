import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/empty_state.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final MapController _mapController = MapController();
  String _contextFilter = 'all';
  String _densityFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Column(
      children: [
        // Filter & Controls Bar
        _buildFilterToolbar(context),

        const SizedBox(height: 16),

        // Main Map Container & Telemetry Inspector
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Surface
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
                          ),
                        ],
                      ),

                      // Clean Empty Overlay Banner (Zero Fake Markers)
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
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No crowd reports available',
                                style: AppTypography.labelSm(
                                  color: AppColors.onSurface,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Map Controls
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: 'map_zoom_in',
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
                              heroTag: 'map_zoom_out',
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
                              heroTag: 'map_recenter',
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

              // Side Inspector Panel
              if (isDesktop) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 360,
                  child: _buildInspectorEmptyPanel(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Context Segment
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MONITORING CONTEXT:',
                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    label: Text('All Zones'),
                    icon: Icon(Icons.grid_view_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 'general',
                    label: Text('Town Sectors'),
                    icon: Icon(Icons.location_city_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 'river',
                    label: Text('Chandrabhaga'),
                    icon: Icon(Icons.water_rounded, size: 16),
                  ),
                ],
                selected: {_contextFilter},
                onSelectionChanged: (set) {
                  setState(() => _contextFilter = set.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStateProperty.all(
                    AppTypography.labelSm(color: AppColors.onSurface),
                  ),
                ),
              ),
            ],
          ),

          // Density Filter Pills
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DENSITY FILTER:',
                style: AppTypography.labelSm(color: AppColors.onSurfaceVariant)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              _buildFilterChip('all', 'All'),
              const SizedBox(width: 6),
              _buildFilterChip('critical', 'Critical', color: AppColors.statusCritical),
              const SizedBox(width: 6),
              _buildFilterChip('high', 'High', color: AppColors.statusHigh),
              const SizedBox(width: 6),
              _buildFilterChip('moderate', 'Moderate', color: AppColors.statusModerate),
              const SizedBox(width: 6),
              _buildFilterChip('normal', 'Normal', color: AppColors.statusNormal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, {Color? color}) {
    final isSelected = _densityFilter == value;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _densityFilter = value;
          });
        }
      },
      visualDensity: VisualDensity.compact,
      labelStyle: AppTypography.labelSm(
        color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
      ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLow,
    );
  }

  Widget _buildInspectorEmptyPanel() {
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
                Text(
                  'Zone Telemetry Inspector',
                  style: AppTypography.labelLg(color: AppColors.onSecondary),
                ),
              ],
            ),
          ),
          const Expanded(
            child: EmptyState(
              title: 'No crowd reports available',
              message:
                  'Clicking on live map markers will inspect sector headcount, density levels, and volunteer report notes.',
              icon: Icons.cell_tower_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
