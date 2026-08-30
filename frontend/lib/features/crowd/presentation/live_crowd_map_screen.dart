import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/extensions/crowd_level_extension.dart';
import '../../../core/models/crowd_condition.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import 'crowd_report_screen.dart';
import '../../routing/presentation/crowd_route_screen.dart';

/// Live Crowd Map Screen displaying real-time crowd condition markers, density summary, and report details.
class LiveCrowdMapScreen extends StatefulWidget {
  const LiveCrowdMapScreen({super.key});

  @override
  State<LiveCrowdMapScreen> createState() => _LiveCrowdMapScreenState();
}

class _LiveCrowdMapScreenState extends State<LiveCrowdMapScreen> {
  final MapController _mapController = MapController();

  List<CrowdReportEntry> _reports = [];
  CrowdSummaryResult? _summary;
  bool _isLoading = true;
  CrowdReportEntry? _selectedReport;

  // Default coordinates centered on Pandharpur Wari corridor
  static const LatLng _pandharpurCenter = LatLng(17.6740, 75.3260);

  @override
  void initState() {
    super.initState();
    _fetchCrowdData();
  }

  Future<void> _fetchCrowdData() async {
    setState(() => _isLoading = true);

    try {
      final reports = await ApiClient.instance.fetchCrowdReports();
      final summary = await ApiClient.instance.fetchCrowdSummary();

      if (mounted) {
        setState(() {
          _reports = reports;
          _summary = summary;
          _isLoading = false;
        });

        // Center map on the latest report if available
        if (reports.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              _mapController.move(
                LatLng(reports.first.latitude, reports.first.longitude),
                15.0,
              );
            } catch (_) {}
          });
        }
      }
    } catch (e) {
      debugPrint('[LiveCrowdMapScreen] Error fetching crowd data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  CrowdLevel _parseCrowdLevel(String levelStr) {
    switch (levelStr.toLowerCase().trim()) {
      case 'critical':
        return CrowdLevel.critical;
      case 'high':
        return CrowdLevel.high;
      case 'moderate':
        return CrowdLevel.moderate;
      case 'normal':
      default:
        return CrowdLevel.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Live Crowd Map',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route_rounded, color: AppColors.primary),
            tooltip: 'Crowd-Aware Alternative Routing',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrowdRouteScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Refresh crowd map',
            onPressed: _fetchCrowdData,
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.primary),
            tooltip: 'Report crowd condition',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrowdReportScreen()),
              );
              _fetchCrowdData();
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Crowd Overview Summary Bar
            _buildCrowdOverviewBar(),

            // Interactive Map Area
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _pandharpurCenter,
                      initialZoom: 14.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sevakconnect.sevak_connect',
                      ),
                      MarkerLayer(
                        markers: _reports.map((report) {
                          final level = _parseCrowdLevel(report.crowdLevel);
                          final isSelected = _selectedReport?.id == report.id;

                          return Marker(
                            point: LatLng(report.latitude, report.longitude),
                            width: isSelected ? 52 : 42,
                            height: isSelected ? 52 : 42,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedReport = report);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: level.color,
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: level.color.withAlpha(120),
                                            blurRadius: 12,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                      : AppShadows.level2,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Loading Overlay
                  if (_isLoading)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(235),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppShadows.level2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                            SizedBox(width: 10),
                            Text('Syncing live crowd reports...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                  // Map Floating Controls: Recenter and Add Report
                  Positioned(
                    right: 16,
                    bottom: _selectedReport != null ? 230 : 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'recenter_map',
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.secondary,
                          onPressed: () {
                            _mapController.move(_pandharpurCenter, 15.0);
                          },
                          child: const Icon(Icons.my_location_rounded),
                        ),
                      ],
                    ),
                  ),

                  // Selected Report Details Card
                  if (_selectedReport != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _buildReportDetailCard(_selectedReport!),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Crowd Overview Header with 4 semantic status chips
  Widget _buildCrowdOverviewBar() {
    final normalCount = _summary?.normal ?? _reports.where((r) => r.crowdLevel == 'normal').length;
    final moderateCount = _summary?.moderate ?? _reports.where((r) => r.crowdLevel == 'moderate').length;
    final highCount = _summary?.high ?? _reports.where((r) => r.crowdLevel == 'high').length;
    final criticalCount = _summary?.critical ?? _reports.where((r) => r.crowdLevel == 'critical').length;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CROWD OVERVIEW',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_reports.length} Reports Active',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSummaryChip(CrowdLevel.normal, normalCount),
              const SizedBox(width: 6),
              _buildSummaryChip(CrowdLevel.moderate, moderateCount),
              const SizedBox(width: 6),
              _buildSummaryChip(CrowdLevel.high, highCount),
              const SizedBox(width: 6),
              _buildSummaryChip(CrowdLevel.critical, criticalCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(CrowdLevel level, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: level.containerColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: level.color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              level.displayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: level.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: level.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Detailed Bottom Floating Card when tapping a crowd marker
  Widget _buildReportDetailCard(CrowdReportEntry report) {
    final level = _parseCrowdLevel(report.crowdLevel);

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.level2,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: level.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      level.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    report.id,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                onPressed: () => setState(() => _selectedReport = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (report.description.isNotEmpty) ...[
            Text(
              report.description,
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              if (report.movementDirection != null && report.movementDirection!.isNotEmpty) ...[
                const Icon(Icons.navigation_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  report.movementDirection!,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
              ],
              if (report.estimatedHeadcount != null && report.estimatedHeadcount! > 0) ...[
                const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '~${report.estimatedHeadcount} people',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          const Divider(height: 14, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By ${report.reportedBy} • ${_formatTime(report.createdAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
