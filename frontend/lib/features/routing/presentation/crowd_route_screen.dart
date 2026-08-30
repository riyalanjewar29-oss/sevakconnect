import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/extensions/crowd_level_extension.dart';
import '../../../core/models/crowd_condition.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';

/// Screen for calculating and visualizing crowd-aware lower-congestion Wari route alternatives following real road geometry.
class CrowdRouteScreen extends StatefulWidget {
  const CrowdRouteScreen({super.key});

  @override
  State<CrowdRouteScreen> createState() => _CrowdRouteScreenState();
}

class _CrowdRouteScreenState extends State<CrowdRouteScreen> {
  final MapController _mapController = MapController();

  // Selected Origin & Destination
  String _selectedOrigin = 'Wakhari Phata Halt';
  String _selectedDestination = 'Vitthal Mandir Complex';

  LatLng _originCoord = const LatLng(17.7020, 75.2900);
  LatLng _destCoord = const LatLng(17.6775, 75.3278);

  bool _isUsingGps = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Route calculation results
  RouteRecommendResult? _recommendResult;
  String? _selectedRouteId;

  final List<Map<String, dynamic>> _originPresets = [
    {
      'name': 'Wakhari Phata Halt',
      'coord': const LatLng(17.7020, 75.2900),
    },
    {
      'name': 'Bhakti Marg Checkpoint',
      'coord': const LatLng(17.6740, 75.3260),
    },
  ];

  final List<Map<String, dynamic>> _destPresets = [
    {
      'name': 'Vitthal Mandir Complex',
      'coord': const LatLng(17.6775, 75.3278),
    },
    {
      'name': 'Chandrabhaga River Ghat',
      'coord': const LatLng(17.6710, 75.3220),
    },
  ];

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  Future<void> _useCurrentGpsOrigin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final gpsPoint = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _isUsingGps = true;
        _selectedOrigin = 'My GPS Location';
        _originCoord = gpsPoint;
      });

      await _calculateRoute();
    } catch (e) {
      debugPrint('[CrowdRouteScreen] GPS error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not acquire GPS position ($e). Using default origin.';
      });
    }
  }

  Future<void> _calculateRoute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiClient.instance.recommendRoute(
        startLat: _originCoord.latitude,
        startLng: _originCoord.longitude,
        destLat: _destCoord.latitude,
        destLng: _destCoord.longitude,
        originName: _selectedOrigin,
        destinationName: _selectedDestination,
      );

      if (mounted) {
        setState(() {
          _recommendResult = result;
          _isLoading = false;
          if (result.isSuccess && result.recommendedRoute != null) {
            _selectedRouteId = result.recommendedRoute!.id;
          } else {
            _errorMessage = result.errorMessage ?? 'Route service unavailable. Please try again.';
          }
        });

        // Fit map bounds to encompass the routes and road geometry
        if (result.isSuccess && result.recommendedRoute != null) {
          final pts = result.recommendedRoute!.points;
          if (pts.isNotEmpty) {
            final midLat = (pts.first.latitude + pts.last.latitude) / 2;
            final midLng = (pts.first.longitude + pts.last.longitude) / 2;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                _mapController.move(LatLng(midLat, midLng), 13.8);
              } catch (_) {}
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Route service unavailable. Please try again.';
        });
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

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase().trim()) {
      case 'critical':
        return AppColors.statusCritical;
      case 'high':
        return AppColors.statusHigh;
      case 'moderate':
        return AppColors.statusModerate;
      case 'low':
      default:
        return AppColors.statusNormal;
    }
  }

  String _formatTimeAgo(String isoTime) {
    if (isoTime.isEmpty) return 'recently';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return 'recently';
    final diff = DateTime.now().toUtc().difference(dt.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final recommended = _recommendResult?.recommendedRoute;
    final alternatives = _recommendResult?.alternatives ?? [];
    final hotspots = _recommendResult?.hotspots ?? [];

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
          'Crowd-Aware Routing',
          style: AppTypography.headlineMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Re-evaluate routes',
            onPressed: _calculateRoute,
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
            // 1. Top Controls & Crowd Level Legend
            _buildHeaderControls(),

            // 2. Error message banner (if network/routing fails)
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                color: const Color(0xFFFFEBEE),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.statusCritical, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.statusCritical, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Interactive OpenStreetMap Area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _originCoord,
                      initialZoom: 13.8,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sevakconnect.sevak_connect',
                      ),

                      // Real Road Polylines Layer
                      PolylineLayer(
                        polylines: [
                          // 1. Render alternative road routes
                          for (int i = 0; i < alternatives.length; i++) ...[
                            Polyline(
                              points: alternatives[i].points
                                  .map((p) => LatLng(p.latitude, p.longitude))
                                  .toList(),
                              strokeWidth: _selectedRouteId == alternatives[i].id ? 5.5 : 3.5,
                              color: _selectedRouteId == alternatives[i].id
                                  ? (i == 0 ? const Color(0xFF3949AB) : const Color(0xFF78909C))
                                  : const Color(0xFF90A4AE).withAlpha(150),
                            ),
                          ],

                          // 2. Render recommended road route on top
                          if (recommended != null)
                            Polyline(
                              points: recommended.points
                                  .map((p) => LatLng(p.latitude, p.longitude))
                                  .toList(),
                              strokeWidth: _selectedRouteId == recommended.id ? 6.0 : 4.5,
                              color: _selectedRouteId == recommended.id
                                  ? AppColors.statusNormal
                                  : AppColors.statusNormal.withAlpha(180),
                            ),
                        ],
                      ),

                      // Markers Layer: Start, End, Crowd Hotspots on roads
                      MarkerLayer(
                        markers: [
                          // START Pin (A)
                          Marker(
                            point: _originCoord,
                            width: 38,
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.statusNormal,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: AppShadows.level2,
                              ),
                              child: const Center(
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // DESTINATION Pin (B)
                          Marker(
                            point: _destCoord,
                            width: 38,
                            height: 38,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: AppShadows.level2,
                              ),
                              child: const Center(
                                child: Text(
                                  'B',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Live Crowd Hotspots on roads
                          for (final h in hotspots) ...[
                            Marker(
                              point: LatLng(h.latitude, h.longitude),
                              width: 32,
                              height: 32,
                              child: GestureDetector(
                                onTap: () => _showHotspotModal(h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _parseCrowdLevel(h.crowdLevel).color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: AppShadows.level1,
                                  ),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),

                  // Loading Overlay
                  if (_isLoading)
                    Positioned(
                      top: 12,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(240),
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
                            Text('Calculating real road geometry & crowd penalties...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                  // Map Route Legend
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppShadows.level1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.statusNormal, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          const Text('Recommended', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF78909C), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          const Text('Alternative', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Bottom Detail Scrollable Cards Panel
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recommended Route Card
                      if (recommended != null) ...[
                        _buildRecommendedRouteCard(recommended),
                        const SizedBox(height: 12),
                      ],

                      // Alternative Route Cards
                      if (alternatives.isNotEmpty) ...[
                        for (int i = 0; i < alternatives.length; i++) ...[
                          _buildAlternativeRouteCard(alternatives[i], i + 1),
                          const SizedBox(height: 10),
                        ],
                      ],

                      // WHY THIS ROUTE IS RECOMMENDED? Card
                      if (recommended != null) ...[
                        const SizedBox(height: 6),
                        _buildWhyRecommendedCard(recommended),
                        const SizedBox(height: 16),
                      ],

                      // Crowd Hotspots on Map Section
                      if (hotspots.isNotEmpty) ...[
                        Text(
                          'CROWD HOTSPOTS ON MAP',
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final h in hotspots) ...[
                          _buildHotspotTile(h),
                          const SizedBox(height: 8),
                        ],
                      ],

                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Road-following geometry retrieved via OpenStreetMap. Route ranking reflects live volunteer crowd observations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top controls with origin/destination selector and crowd level legend
  Widget _buildHeaderControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Origin Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trip_origin_rounded, color: AppColors.statusNormal, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _isUsingGps ? 'My GPS Location' : _selectedOrigin,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            items: [
                              if (_isUsingGps)
                                const DropdownMenuItem(
                                  value: 'My GPS Location',
                                  child: Text('My GPS Location', overflow: TextOverflow.ellipsis),
                                ),
                              ..._originPresets.map((p) => DropdownMenuItem<String>(
                                    value: p['name'] as String,
                                    child: Text(p['name'] as String, overflow: TextOverflow.ellipsis),
                                  )),
                            ],
                            onChanged: (val) {
                              if (val != null && val != 'My GPS Location') {
                                final match = _originPresets.firstWhere((p) => p['name'] == val);
                                setState(() {
                                  _isUsingGps = false;
                                  _selectedOrigin = val;
                                  _originCoord = match['coord'] as LatLng;
                                });
                                _calculateRoute();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // GPS Button
              IconButton.filledTonal(
                icon: const Icon(Icons.my_location_rounded, size: 18),
                tooltip: 'Use current GPS location',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer.withAlpha(50),
                  foregroundColor: AppColors.primary,
                ),
                onPressed: _useCurrentGpsOrigin,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Destination Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDestination,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      items: _destPresets.map((p) => DropdownMenuItem<String>(
                            value: p['name'] as String,
                            child: Text(p['name'] as String, overflow: TextOverflow.ellipsis),
                          )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final match = _destPresets.firstWhere((p) => p['name'] == val);
                          setState(() {
                            _selectedDestination = val;
                            _destCoord = match['coord'] as LatLng;
                          });
                          _calculateRoute();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Crowd Level Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendChip(CrowdLevel.normal, 'Normal'),
              _buildLegendChip(CrowdLevel.moderate, 'Moderate'),
              _buildLegendChip(CrowdLevel.high, 'High'),
              _buildLegendChip(CrowdLevel.critical, 'Critical'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendChip(CrowdLevel level, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: level.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Recommended Route Card
  Widget _buildRecommendedRouteCard(RouteOptionData route) {
    final isSelected = _selectedRouteId == route.id;

    return InkWell(
      onTap: () => setState(() => _selectedRouteId = route.id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9), // Light green tint
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.statusNormal : const Color(0xFFC8E6C9),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.statusNormal, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'RECOMMENDED ROUTE',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.statusNormal,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LOW CONGESTION',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Via ${route.viaRoad.isNotEmpty ? route.viaRoad : route.name}',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${route.distanceKm} km • ${route.estimatedTimeMins} min',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                if (route.avoidedHotspotsCount > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• Avoids ${route.avoidedHotspotsCount} crowd zone${route.avoidedHotspotsCount > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Alternative Route Card
  Widget _buildAlternativeRouteCard(RouteOptionData route, int index) {
    final isSelected = _selectedRouteId == route.id;
    final riskColor = _getRiskColor(route.crowdRisk);

    return InkWell(
      onTap: () => setState(() => _selectedRouteId = route.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALTERNATIVE ROUTE $index',
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: riskColor.withAlpha(70)),
                  ),
                  child: Text(
                    '${route.crowdRisk.toUpperCase()} CONGESTION',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: riskColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Via ${route.viaRoad.isNotEmpty ? route.viaRoad : route.name}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${route.distanceKm} km • ${route.estimatedTimeMins} min',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                if (route.affectedReportsCount > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• Passes ${route.affectedReportsCount} crowd hotspot${route.affectedReportsCount > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 11, color: riskColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// WHY THIS ROUTE IS RECOMMENDED? Card
  Widget _buildWhyRecommendedCard(RouteOptionData route) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE775)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF558B2F)),
              const SizedBox(width: 6),
              Text(
                'WHY THIS ROUTE IS RECOMMENDED?',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF33691E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            route.recommendationReason,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Crowd Hotspot Tile
  Widget _buildHotspotTile(CrowdHotspotDetailData hotspot) {
    final level = _parseCrowdLevel(hotspot.crowdLevel);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hotspot.locationName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                    Text(
                      _formatTimeAgo(hotspot.createdAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${level.displayName} Crowd${hotspot.estimatedHeadcount != null && hotspot.estimatedHeadcount! > 0 ? " • ~${hotspot.estimatedHeadcount} people" : ""}',
                  style: TextStyle(fontSize: 11, color: level.color, fontWeight: FontWeight.w600),
                ),
                if (hotspot.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    hotspot.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHotspotModal(CrowdHotspotDetailData hotspot) {
    final level = _parseCrowdLevel(hotspot.crowdLevel);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: level.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${level.displayName.toUpperCase()} CROWD',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Text(
                    hotspot.id,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(hotspot.locationName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              if (hotspot.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(hotspot.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 6),
              if (hotspot.estimatedHeadcount != null && hotspot.estimatedHeadcount! > 0)
                Text('Estimated Headcount: ~${hotspot.estimatedHeadcount} people', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Divider(height: 16),
              Text(
                'Reported ${_formatTimeAgo(hotspot.createdAt)} at ${hotspot.latitude.toStringAsFixed(4)}, ${hotspot.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}
